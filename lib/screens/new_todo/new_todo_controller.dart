import 'dart:convert';

import 'package:donow/database/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:ndk/shared/nips/nip44/nip44.dart';

class NewTodoController extends GetxController {
  static NewTodoController get to => Get.find();

  final descriptionController = TextEditingController();

  String get todoDescription => descriptionController.text.trim();
  bool get canCreateTodo => todoDescription.isNotEmpty;

  void createTodo() async {
    if (!canCreateTodo) return;

    final ndk = Get.find<Ndk>();
    final pubkey = ndk.accounts.getPublicKey()!;
    final privkey = (await FlutterSecureStorage().read(key: "privkey"))!;
    final encryptedDescription = await Nip44.encryptMessage(
      todoDescription,
      privkey,
      pubkey,
    );

    final event = Nip01Event(
      pubKey: pubkey,
      kind: 713,
      tags: [["encrypted", "NIP-44"]],
      content: encryptedDescription,
    );
    ndk.broadcast.broadcast(nostrEvent: event);

    final database = Get.find<AppDatabase>();
    await database
        .into(database.decryptedEventItems)
        .insert(
          DecryptedEventItemsCompanion.insert(
            id: event.id,
            content: jsonEncode({"content": todoDescription}),
          ),
        );

    Get.back();
  }
}
