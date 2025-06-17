import 'package:donow/app_routes.dart';
import 'package:donow/repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("Donow sign in", style: Theme.of(context).textTheme.displaySmall,),
                TextField(
                  decoration: InputDecoration(labelText: "Nsec"),
                  onChanged: (nsec) async {
                    KeyPair? keyPair;
                    try {
                      keyPair = Nip19KeyPair.fromNsec(nsec);
                    } catch (e) {
                      return;
                    }
                    
                    Get.find<Ndk>().accounts.loginPrivateKey(
                      pubkey: keyPair.publicKey,
                      privkey: keyPair.privateKey,
                    );
                
                    await FlutterSecureStorage().write(key: "privkey", value: keyPair.privateKey);

                    Repository.to.listenTodo();
                
                    Get.offNamed(AppRoutes.todo);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
