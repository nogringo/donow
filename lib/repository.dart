import 'package:donow/app_routes.dart';
import 'package:donow/get_database.dart';
import 'package:donow/models/todo.dart';
import 'package:donow/services/update_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:sembast/sembast.dart' as sembast;

class Repository extends GetxController {
  static Repository get to => Get.find();

  NdkResponse? userSub;

  RxBool hasUpdate = false.obs;
  RxList<Todo> todosList = <Todo>[].obs;

  // Database and stores
  late sembast.Database _database;
  late sembast.StoreRef<String, Map<String, dynamic>> _todoEventsStore;
  late sembast.StoreRef<String, bool> _deletedEventsStore;

  Ndk get ndk => Get.find<Ndk>();
  String get pubkey => ndk.accounts.getPublicKey()!;

  Future<void> loadApp() async {
    // Initialize database
    await initDatabase();

    listenTodo();
    checkForUpdate();
  }

  Future<void> initDatabase() async {
    final dbName = kDebugMode ? 'donow_dev_db' : 'donow_db';
    _database = await getDatabase(dbName);

    // Initialize stores
    _todoEventsStore = sembast.stringMapStoreFactory.store('todo_events');
    _deletedEventsStore = sembast.StoreRef<String, bool>.main();
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

      // Handle different event kinds
      if (event.kind == 5) {
        // Store deleted event IDs and remove the events
        List<String> targetEventIds = event.getTags("e");
        for (var id in targetEventIds) {
          // Store in deleted events store
          await _deletedEventsStore.record(id).put(_database, true);
          // Remove from todo events store
          await _todoEventsStore.record(id).delete(_database);
        }
      } else {
        // Check if this event is deleted before processing
        final isDeleted = await _deletedEventsStore
            .record(event.id)
            .get(_database);
        if (isDeleted != null && isDeleted) {
          continue;
        }

        // Check if event already exists
        final existingEvent = await _todoEventsStore
            .record(event.id)
            .get(_database);
        if (existingEvent != null) {
          continue;
        }

        if (event.kind == 713) {
          // Store todo event with decrypted content
          final decryptedContent = await _decryptTodoContent(event);
          await _todoEventsStore.record(event.id).put(_database, {
            'nostrEvent': event.toJson(),
            'decryptedContent': decryptedContent,
          });
        } else if (event.kind == 714) {
          // Store status event (no decryption needed)
          await _todoEventsStore.record(event.id).put(_database, {
            'nostrEvent': event.toJson(),
            'decryptedContent': null,
          });
        }
      }

      // Trigger UI update
      update();
    }
  }

  Future<String> _decryptTodoContent(Nip01Event event) async {
    try {
      final description = await ndk.accounts
          .getLoggedAccount()!
          .signer
          .decryptNip44(ciphertext: event.content, senderPubKey: pubkey);
      return description ?? '';
    } catch (e) {
      return '';
    }
  }

  // Store todo locally for offline-first support
  Future<void> storeTodoLocally(
    Nip01Event event,
    String decryptedContent,
  ) async {
    // Check if already exists
    final existingEvent = await _todoEventsStore
        .record(event.id)
        .get(_database);
    if (existingEvent != null) {
      return;
    }

    // Store the event locally
    await _todoEventsStore.record(event.id).put(_database, {
      'nostrEvent': event.toJson(),
      'decryptedContent': decryptedContent,
    });

    // Trigger UI update
    update();
  }

  void stopListenTodo() {
    if (userSub == null) return;

    ndk.requests.closeSubscription(userSub!.requestId);
  }

  Future<List<Todo>> todos() async {
    List<Todo> result = [];

    // Get all todo events for the current user
    final finder = sembast.Finder(
      filter: sembast.Filter.equals('nostrEvent.pubkey', pubkey),
    );
    final records = await _todoEventsStore.find(_database, finder: finder);

    // Build completion status map from kind 714 events
    Map<String, bool> completionStatus = {};
    for (var record in records) {
      final data = record.value;
      final nostrEvent = data['nostrEvent'];

      if (nostrEvent['kind'] == 714 && nostrEvent['content'] == 'DONE') {
        // Get the referenced todo ID from tags
        final tags = nostrEvent['tags'] as List;
        for (var tag in tags) {
          if (tag is List && tag.length > 1 && tag[0] == 'e') {
            completionStatus[tag[1]] = true;
            break;
          }
        }
      }
    }

    // Build todo list from kind 713 events
    for (var record in records) {
      final data = record.value;
      final nostrEvent = data['nostrEvent'];

      if (nostrEvent['kind'] == 713) {
        final decryptedContent = data['decryptedContent'] ?? '';

        result.add(
          Todo(
            eventId: nostrEvent['id'],
            description: decryptedContent,
            isCompleted: completionStatus[nostrEvent['id']] ?? false,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              nostrEvent['created_at'] * 1000,
            ),
          ),
        );
      }
    }

    // Sort todos
    result.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  Future<String> getTodoDescription(Nip01Event event) async {
    // This method is no longer needed since we decrypt when storing
    // But keeping it for compatibility
    final record = await _todoEventsStore.record(event.id).get(_database);
    if (record != null && record['decryptedContent'] != null) {
      return record['decryptedContent'];
    }

    // If not found, decrypt and return
    final description = await ndk.accounts
        .getLoggedAccount()!
        .signer
        .decryptNip44(ciphertext: event.content, senderPubKey: pubkey);

    return description ?? '';
  }

  Future<void> completeTodo(String eventId) async {
    // Check if already marked as completed
    final finder = sembast.Finder(
      filter: sembast.Filter.and([
        sembast.Filter.equals('nostrEvent.kind', 714),
        sembast.Filter.equals('nostrEvent.pubkey', pubkey),
      ]),
    );
    final statusEvents = await _todoEventsStore.find(_database, finder: finder);

    for (var record in statusEvents) {
      final nostrEvent = record.value['nostrEvent'];
      final tags = nostrEvent['tags'] as List;
      for (var tag in tags) {
        if (tag is List &&
            tag.length > 1 &&
            tag[0] == 'e' &&
            tag[1] == eventId) {
          return; // Already marked as completed
        }
      }
    }

    final event = Nip01Event(
      pubKey: pubkey,
      kind: 714,
      tags: [
        ["e", eventId],
      ],
      content: "DONE",
    );

    // Store locally first (offline-first)
    await _todoEventsStore.record(event.id).put(_database, {
      'nostrEvent': event.toJson(),
      'decryptedContent': null,
    });

    // Trigger UI update immediately
    update();

    // Then broadcast to network
    ndk.broadcast.broadcast(nostrEvent: event);
  }

  Future<void> toggleCompleteTodo(String eventId) async {
    // Check if marked as completed
    final finder = sembast.Finder(
      filter: sembast.Filter.and([
        sembast.Filter.equals('nostrEvent.kind', 714),
        sembast.Filter.equals('nostrEvent.pubkey', pubkey),
      ]),
    );
    final statusEvents = await _todoEventsStore.find(_database, finder: finder);
    List<String> markerIds = [];

    for (var record in statusEvents) {
      final nostrEvent = record.value['nostrEvent'];
      final tags = nostrEvent['tags'] as List;
      for (var tag in tags) {
        if (tag is List &&
            tag.length > 1 &&
            tag[0] == 'e' &&
            tag[1] == eventId) {
          markerIds.add(nostrEvent['id']);
        }
      }
    }

    if (markerIds.isEmpty) {
      completeTodo(eventId);
      return;
    }

    for (var markerId in markerIds) {
      // Store deletion locally first
      await _deletedEventsStore.record(markerId).put(_database, true);
      await _todoEventsStore.record(markerId).delete(_database);

      // Then broadcast deletion
      ndk.broadcast.broadcastDeletion(eventId: markerId);
    }

    // Trigger UI update
    update();
  }

  Future<void> deleteTodo(String eventId) async {
    List<String> eventIdsToDelete = [eventId];

    // Find related status events
    final finder = sembast.Finder(
      filter: sembast.Filter.and([
        sembast.Filter.equals('nostrEvent.kind', 714),
        sembast.Filter.equals('nostrEvent.pubkey', pubkey),
      ]),
    );
    final statusEvents = await _todoEventsStore.find(_database, finder: finder);

    for (var record in statusEvents) {
      final nostrEvent = record.value['nostrEvent'];
      final tags = nostrEvent['tags'] as List;
      for (var tag in tags) {
        if (tag is List &&
            tag.length > 1 &&
            tag[0] == 'e' &&
            tag[1] == eventId) {
          eventIdsToDelete.add(nostrEvent['id']);
        }
      }
    }

    // Store deletions locally first
    for (var id in eventIdsToDelete) {
      await _deletedEventsStore.record(id).put(_database, true);
      await _todoEventsStore.record(id).delete(_database);
    }

    // Trigger UI update
    update();

    // Then broadcast deletions to network
    for (var id in eventIdsToDelete) {
      ndk.broadcast.broadcastDeletion(eventId: id);
    }
  }

  Future<void> deleteAllCompletedTodos() async {
    final todos = await this.todos();
    final completedTodos = todos.where((todo) => todo.isCompleted).toList();

    if (completedTodos.isEmpty) return;

    List<String> eventIdsToDelete = [];

    // Collect all event IDs (todos and their completion markers)
    final finder = sembast.Finder(
      filter: sembast.Filter.and([
        sembast.Filter.equals('nostrEvent.kind', 714),
        sembast.Filter.equals('nostrEvent.pubkey', pubkey),
      ]),
    );
    final statusEvents = await _todoEventsStore.find(_database, finder: finder);

    for (var todo in completedTodos) {
      eventIdsToDelete.add(todo.eventId);

      // Find related status events
      for (var record in statusEvents) {
        final nostrEvent = record.value['nostrEvent'];
        final tags = nostrEvent['tags'] as List;
        for (var tag in tags) {
          if (tag is List &&
              tag.length > 1 &&
              tag[0] == 'e' &&
              tag[1] == todo.eventId) {
            eventIdsToDelete.add(nostrEvent['id']);
          }
        }
      }
    }

    // Send a single deletion event with all IDs
    final deleteEvent = Nip01Event(
      pubKey: pubkey,
      kind: 5,
      tags: eventIdsToDelete.map((id) => ["e", id]).toList(),
      content: "Bulk delete completed todos",
    );

    ndk.broadcast.broadcast(nostrEvent: deleteEvent);
    // Remove all deleted todos from local database
    for (var id in eventIdsToDelete) {
      await _todoEventsStore.record(id).delete(_database);
    }
  }

  void logOut() async {
    stopListenTodo();

    await FlutterSecureStorage().delete(key: "privkey");
    await FlutterSecureStorage().delete(key: "loginWith");
    ndk.accounts.logout();

    Get.offAllNamed(AppRoutes.signIn);
  }
}
