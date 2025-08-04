import 'dart:convert';

import 'package:donow/app_routes.dart';
import 'package:donow/database/database.dart';
import 'package:donow/models/todo.dart';
import 'package:donow/services/update_checker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

class Repository extends GetxController {
  static Repository get to => Get.find();

  NdkResponse? userSub;

  List<String> deletedEventIds = [];
  List<Nip01Event> todoEvents = [];
  
  RxBool hasUpdate = true.obs;

  Ndk get ndk => Get.find<Ndk>();
  String get pubkey => ndk.accounts.getPublicKey()!;
  AppDatabase get database => Get.find<AppDatabase>();

  Future<void> loadApp() async {
    listenTodo();
    // checkForUpdate();
  }
  
  Future<void> checkForUpdate() async {
    final updateInfo = await UpdateChecker.checkForUpdate();
    if (updateInfo != null) {
      hasUpdate.value = updateInfo.hasUpdate;
    }
  }

  void listenTodo() async {
    stopListenTodo();

    userSub = ndk.requests.subscription(
      filters: [
        Filter(kinds: [5, 713, 714], authors: [pubkey]),
      ],
      cacheRead: true,
      cacheWrite: true,
    );

    await for (final event in userSub!.stream) {
      if (event.kind == 5) {
        List<String> targetEventIds = event.getTags("e");

        todoEvents.removeWhere((e) => targetEventIds.contains(e.id));
        deletedEventIds.addAll(targetEventIds);

        update();
        continue;
      }

      if (deletedEventIds.contains(event.id)) continue;

      todoEvents.add(event);

      if (event.kind == 713) {
        getTodoDescription(event);
      }

      update();
    }
  }

  void stopListenTodo() {
    if (userSub == null) return;

    ndk.requests.closeSubscription(userSub!.requestId);
  }

  Future<List<Todo>> todos() async {
    List<Todo> result = [];

    final eventsKind713 = todoEvents.where((e) => e.kind == 713);

    for (var event in eventsKind713) {
      List<Nip01Event> statuEvents = todoEvents
          .where((e) => e.kind == 714 && e.getFirstTag("e") == event.id)
          .toList();

      bool isCompleted = false;
      if (statuEvents.isNotEmpty && statuEvents.first.content == "DONE") {
        isCompleted = true;
      }

      result.add(
        Todo(
          eventId: event.id,
          description: await getTodoDescription(event),
          isCompleted: isCompleted,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            event.createdAt * 1000,
          ),
        ),
      );
    }

    result.sort((a, b) {
      // First sort by completion status (incomplete first)
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  Future<String> getTodoDescription(Nip01Event event) async {
    //! unexpected error
    // final decryptedContent = await (database.select(
    //   database.decryptedEventItems,
    // )..where((row) => row.id.isValue(event.id))).getSingleOrNull();

    final queryRes = await (database.select(
      database.decryptedEventItems,
    )..where((row) => row.id.isValue(event.id))).get();

    DecryptedEventItem? decryptedContent;
    if (queryRes.isNotEmpty) decryptedContent = queryRes.first;
    //! this code above is used as replacement

    if (decryptedContent != null) {
      return jsonDecode(decryptedContent.content)["content"];
    }

    final description = await ndk.accounts
        .getLoggedAccount()!
        .signer
        .decryptNip44(ciphertext: event.content, senderPubKey: pubkey);

    await database
        .into(database.decryptedEventItems)
        .insert(
          DecryptedEventItemsCompanion.insert(
            id: event.id,
            content: jsonEncode({"content": description!}),
          ),
        );

    return description;
  }

  void completeTodo(String eventId) {
    final isAlreadyMarkedAsCompleted = todoEvents
        .where((e) => e.kind == 714 && e.getEId() == eventId)
        .map((e) => e.id)
        .isNotEmpty;

    if (isAlreadyMarkedAsCompleted) return;

    final event = Nip01Event(
      pubKey: pubkey,
      kind: 714,
      tags: [
        ["e", eventId],
      ],
      content: "DONE",
    );
    ndk.broadcast.broadcast(nostrEvent: event);
  }

  void toggleCompleteTodo(String eventId) {
    List<Nip01Event>? completedMarkers = todoEvents
        .where((e) => e.kind == 714 && e.getEId() == eventId)
        .toList();

    if (completedMarkers.isEmpty) {
      completeTodo(eventId);
      return;
    }

    for (var marker in completedMarkers) {
      ndk.broadcast.broadcastDeletion(eventId: marker.id);
    }
  }

  void deleteTodo(String eventId) {
    List<String> eventIdsToDelete = [eventId];

    eventIdsToDelete.addAll(
      todoEvents
          .where((e) => e.kind == 714 && e.getEId() == eventId)
          .map((e) => e.id),
    );

    for (var eventId in eventIdsToDelete) {
      ndk.broadcast.broadcastDeletion(eventId: eventId);
    }
  }

  void logOut() async {
    stopListenTodo();

    await FlutterSecureStorage().delete(key: "privkey");
    await FlutterSecureStorage().delete(key: "loginWith");
    ndk.accounts.logout();
    todoEvents.clear();
    deletedEventIds.clear();

    Get.offAllNamed(AppRoutes.signIn);
  }
}
