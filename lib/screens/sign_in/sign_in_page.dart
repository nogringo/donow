import 'package:donow/app_routes.dart';
import 'package:donow/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nip01/nip01.dart';
import 'package:nip19/nip19.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:window_manager/window_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nip07_event_signer/nip07_event_signer.dart';
import 'package:donow/l10n/app_localizations.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            actions: [
              if (!kIsWeb && GetPlatform.isDesktop)
                SizedBox(
                  width: 154,
                  child: WindowCaption(
                    brightness: Theme.of(context).brightness,
                    backgroundColor: Colors.transparent,
                  ),
                ),
            ],
          ),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 350),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppLocalizations.of(context)!.signInTitle,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                TextField(
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.nsecLabel),
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

                    await FlutterSecureStorage().write(
                      key: "loginWith",
                      value: "nsec",
                    );

                    await FlutterSecureStorage().write(
                      key: "privkey",
                      value: keyPair.privateKey,
                    );

                    Repository.to.listenTodo();

                    Get.offNamed(AppRoutes.todo);
                  },
                ),
                if (kIsWeb) SizedBox(height: 16),
                if (kIsWeb)
                  Center(
                    child: Opacity(
                      opacity: 0.8,
                      child: Text(
                        AppLocalizations.of(context)!.or,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (kIsWeb) SizedBox(height: 16),
                if (kIsWeb) ExtensionSignInButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ExtensionSignInButton extends StatelessWidget {
  const ExtensionSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final nip07Signer = Nip07EventSigner();

    final nip07CanSign = nip07Signer.canSign();

    return FilledButton.icon(
      onPressed: () async {
        if (!nip07CanSign) {
          await launchUrl(
            Uri.parse(
              'https://chromewebstore.google.com/detail/nos2x/kpgefcfmnafjgpblomihpgmejjdanjjp',
            ),
          );
          return;
        }

        try {
          await nip07Signer.getPublicKeyAsync();
        } catch (e) {
          return;
        }

        Get.find<Ndk>().accounts.loginExternalSigner(signer: nip07Signer);

        await FlutterSecureStorage().write(
          key: "loginWith",
          value: "extension",
        );

        Repository.to.listenTodo();

        Get.offNamed(AppRoutes.todo);
      },
      label: Text(nip07CanSign ? AppLocalizations.of(context)!.extensionLogin : AppLocalizations.of(context)!.installExtension),
      icon: Icon(Icons.extension_outlined),
    );
  }
}
