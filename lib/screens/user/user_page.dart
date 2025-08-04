import 'package:donow/app_routes.dart';
import 'package:donow/l10n/app_localizations.dart';
import 'package:donow/repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:window_manager/window_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: DragToMoveArea(
          child: AppBar(
            title: Text(AppLocalizations.of(context)!.profile),
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
          constraints: BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              NUserProfile(
                ndk: Repository.to.ndk,
                onLogout: () {
                  Get.offAllNamed(AppRoutes.signIn);
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64),
                child: UpdateView(),
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateView extends StatelessWidget {
  const UpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!Repository.to.hasUpdate.value) return Container();

      return Card(
        margin: EdgeInsets.all(0),
        elevation: 0,
        child: ListTile(
          title: Text(AppLocalizations.of(context)!.updateAvailable),
          trailing: kIsWeb
              ? Text(AppLocalizations.of(context)!.reloadThisPage)
              : OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(
                      'https://github.com/nogringo/donow/releases/latest',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  label: Text(AppLocalizations.of(context)!.download),
                  icon: Icon(Icons.vertical_align_bottom),
                ),
        ),
      );
    });
  }
}
