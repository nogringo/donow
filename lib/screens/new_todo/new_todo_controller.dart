import 'dart:convert';

import 'package:donow/database/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';

class NewTodoController extends GetxController {
  static NewTodoController get to => Get.find();

  final descriptionController = TextEditingController();

  String get todoDescription => descriptionController.text.trim();
  bool get canCreateTodo => todoDescription.isNotEmpty;

  void createTodo() async {
    if (!canCreateTodo) return;

    final ndk = Get.find<Ndk>();
    final pubkey = ndk.accounts.getPublicKey()!;
    final encryptedDescription = await ndk.accounts
        .getLoggedAccount()!
        .signer
        .encryptNip44(plaintext: todoDescription, recipientPubKey: pubkey);

    final event = Nip01Event(
      pubKey: pubkey,
      kind: 713,
      tags: [
        ["encrypted", "NIP-44"],
      ],
      content: encryptedDescription!,
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
