import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Donow'**
  String get appTitle;

  /// Title for the sign in page
  ///
  /// In en, this message translates to:
  /// **'Donow sign in'**
  String get signInTitle;

  /// Label for the nsec input field
  ///
  /// In en, this message translates to:
  /// **'Nsec'**
  String get nsecLabel;

  /// Text separating login options
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// Button text for logging in with browser extension
  ///
  /// In en, this message translates to:
  /// **'Extension login'**
  String get extensionLogin;

  /// Button text for installing the browser extension
  ///
  /// In en, this message translates to:
  /// **'Install extension'**
  String get installExtension;

  /// Button text for creating a new todo
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Placeholder text for the todo input field
  ///
  /// In en, this message translates to:
  /// **'What do you have to do ?'**
  String get whatToDo;

  /// Button text for deleting a todo
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// User profile page title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Text shown when an update is available
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// Text shown for web users to reload the page
  ///
  /// In en, this message translates to:
  /// **'Reload this page'**
  String get reloadThisPage;

  /// Button text for downloading an update
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Label for active todos
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Label for completed todos
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Message shown when there are no active tasks
  ///
  /// In en, this message translates to:
  /// **'No active tasks'**
  String get noActiveTasks;

  /// Message shown when there are no completed tasks
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet'**
  String get noCompletedTasks;

  /// Action to mark a completed task as incomplete
  ///
  /// In en, this message translates to:
  /// **'Mark as incomplete'**
  String get markAsIncomplete;

  /// Export todos as markdown
  ///
  /// In en, this message translates to:
  /// **'Export as Markdown'**
  String get exportAsMarkdown;

  /// Success message when todos are copied
  ///
  /// In en, this message translates to:
  /// **'Todos copied to clipboard'**
  String get todosCopiedToClipboard;

  /// Error message when copy fails
  ///
  /// In en, this message translates to:
  /// **'Failed to copy'**
  String get failedToCopy;

  /// Success message when todos are downloaded
  ///
  /// In en, this message translates to:
  /// **'Todos downloaded successfully'**
  String get todosDownloadedSuccessfully;

  /// Error message when download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download'**
  String get failedToDownload;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
