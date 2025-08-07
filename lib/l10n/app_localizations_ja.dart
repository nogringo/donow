// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Donow';

  @override
  String get signInTitle => 'Donow サインイン';

  @override
  String get nsecLabel => 'Nsec';

  @override
  String get or => 'または';

  @override
  String get extensionLogin => '拡張機能でログイン';

  @override
  String get installExtension => '拡張機能をインストール';

  @override
  String get create => '作成';

  @override
  String get whatToDo => '何をしなければなりませんか？';

  @override
  String get delete => '削除';

  @override
  String get profile => 'プロフィール';

  @override
  String get updateAvailable => 'アップデート利用可能';

  @override
  String get reloadThisPage => 'このページを再読み込み';

  @override
  String get download => 'ダウンロード';

  @override
  String get active => 'アクティブ';

  @override
  String get completed => '完了';

  @override
  String get noActiveTasks => 'アクティブなタスクはありません';

  @override
  String get noCompletedTasks => '完了したタスクはまだありません';

  @override
  String get markAsIncomplete => '未完了にする';

  @override
  String get exportAsMarkdown => 'Markdownとしてエクスポート';

  @override
  String get todosCopiedToClipboard => 'タスクをクリップボードにコピーしました';

  @override
  String get failedToCopy => 'コピーに失敗しました';

  @override
  String get todosDownloadedSuccessfully => 'タスクを正常にダウンロードしました';

  @override
  String get failedToDownload => 'ダウンロードに失敗しました';

  @override
  String get clearAll => 'すべてクリア';

  @override
  String get deleteAllCompleted => '完了したタスクをすべて削除';

  @override
  String get deleteAllCompletedConfirmation =>
      '完了したタスクをすべて削除してもよろしいですか？この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';
}
