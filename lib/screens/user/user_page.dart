import 'package:donow/app_routes.dart';
import 'package:donow/l10n/app_localizations.dart';
import 'package:nostr_todo_sdk/nostr_todo_sdk.dart';
import 'package:donow/repository.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nostr_widgets/nostr_widgets.dart';
import 'package:toastification/toastification.dart';
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
                child: ExportTodosButton(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
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

class ExportTodosButton extends StatelessWidget {
  const ExportTodosButton({super.key});

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      // Get todos from repository
      final todos = await Repository.to.todos();

      // Generate markdown content
      final markdown = _generateMarkdown(todos);

      // Copy to clipboard
      await Clipboard.setData(ClipboardData(text: markdown));

      if (!context.mounted) return;

      toastification.show(
        context: context,
        title: Text(AppLocalizations.of(context)!.todosCopiedToClipboard),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (!context.mounted) return;

      toastification.show(
        context: context,
        title: Text(AppLocalizations.of(context)!.failedToCopy),
        description: Text('$e'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context) async {
    try {
      // Get todos from repository
      final todos = await Repository.to.todos();

      // Generate markdown content
      final markdown = _generateMarkdown(todos);

      // Convert to bytes
      final bytes = Uint8List.fromList(markdown.codeUnits);

      // Generate filename with timestamp
      final fileName =
          'todos_${DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now())}.md';

      // Save file
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: bytes,
        mimeType: MimeType.text,
      );

      if (!context.mounted) return;

      toastification.show(
        context: context,
        title: Text(AppLocalizations.of(context)!.todosDownloadedSuccessfully),
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (!context.mounted) return;

      toastification.show(
        context: context,
        title: Text(AppLocalizations.of(context)!.failedToDownload),
        description: Text('$e'),
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        alignment: Alignment.bottomRight,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }

  String _generateMarkdown(List<Todo> todos) {
    final buffer = StringBuffer();

    for (final todo in todos) {
      if (todo.isCompleted) {
        buffer.writeln('- [x] ${todo.description}');
      } else {
        buffer.writeln('- [ ] ${todo.description}');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          child: ListTile(
            leading: Icon(Icons.cloud_download),
            title: Text(AppLocalizations.of(context)!.exportAsMarkdown),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _copyToClipboard(context),
                  icon: Icon(Icons.copy),
                ),
                IconButton(
                  onPressed: () => _downloadFile(context),
                  icon: Icon(Icons.save_alt),
                ),
              ],
            ),
          ),
        ),
      ],
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
