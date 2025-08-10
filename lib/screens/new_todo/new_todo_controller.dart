import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:donow/repository.dart';

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
    
    // Store locally first (offline-first)
    await Repository.to.storeTodoLocally(event, todoDescription);
    
    // Then broadcast to network
    ndk.broadcast.broadcast(nostrEvent: event);

    Get.back();
  }
}
