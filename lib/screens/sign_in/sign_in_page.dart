import 'package:donow/app_routes.dart';
import 'package:donow/config.dart';
import 'package:donow/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:window_manager/window_manager.dart';
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
                NLogin(
                  ndk: Repository.to.ndk,
                  enablePubkeyLogin: false,
                  nostrConnect: NostrConnect(
                    relays: [
                      "wss://relay.nsec.app",
                      "wss://theforest.nostr1.com",
                      "wss://nostr.oxtr.dev",
                      "wss://relay.primal.net",
                    ],
                    appName: appTitle,
                  ),
                  onLoggedIn: () {
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
