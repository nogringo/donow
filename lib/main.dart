import 'package:donow/app_routes.dart';
import 'package:donow/config.dart';
import 'package:donow/get_database.dart';
import 'package:donow/middlewares/router_is_logged_in_middleware.dart';
import 'package:donow/repository.dart';
import 'package:donow/screens/new_todo/new_todo_page.dart';
import 'package:donow/screens/sign_in/sign_in_page.dart';
import 'package:donow/screens/home/home_page.dart';
import 'package:donow/screens/user/user_page.dart';
import 'package:donow/screens/switch_account/switch_account_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/config/bootstrap_relays.dart';
import 'package:ndk_rust_verifier/ndk_rust_verifier.dart';
import 'package:nostr_widgets/functions/functions.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ndk/ndk.dart';
import 'package:system_theme/system_theme.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:nostr_widgets/l10n/app_localizations.dart' as nostr_widgets;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
  }

  await SystemTheme.accentColor.load();

  // For Android: use 10.0.2.2 for emulator or your machine's IP for physical device
  // For other platforms: use localhost
  String getDebugRelayUrl() {
    if (GetPlatform.isAndroid) {
      // Use 10.0.2.2 for Android emulator, or replace with your machine's IP
      return 'ws://10.0.2.2:7777';
    }
    return 'ws://localhost:7777';
  }

  final ndk = Ndk(
    NdkConfig(
      eventVerifier: RustEventVerifier(),
      cache: SembastCacheManager(await getDatabase()),
      bootstrapRelays: kDebugMode
          ? [getDebugRelayUrl()]
          : DEFAULT_BOOTSTRAP_RELAYS,
    ),
  );
  Get.put(ndk);

  await nRestoreAccounts(ndk);

  final repository = Repository();
  Get.put(repository);
  await repository.loadApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemThemeBuilder(
      builder: (context, accent) {
        final supportAccentColor = defaultTargetPlatform.supportsAccentColor;
        Color accentColor = supportAccentColor
            ? accent.accent
            : accent.defaultAccentColor;
        if (kIsWeb) accentColor = Colors.teal;

        ThemeData getTheme([Brightness? brightness]) {
          brightness = brightness ?? Brightness.light;
          final bool isLightTheme = brightness == Brightness.light;

          final colorScheme = ColorScheme.fromSeed(
            seedColor: accentColor,
            brightness: brightness,
          );

          return ThemeData(
            appBarTheme: AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarBrightness: isLightTheme
                    ? Brightness.dark
                    : Brightness.light, //! It does not switch on emulator
                systemNavigationBarColor: colorScheme.surface,
                systemNavigationBarIconBrightness: isLightTheme
                    ? Brightness.dark
                    : Brightness.light,
              ),
            ),
            colorScheme: colorScheme,
            brightness: brightness,
          );
        }

        final app = ToastificationWrapper(
          child: GetMaterialApp(
            title: appTitle,
            theme: getTheme(),
            darkTheme: getTheme(Brightness.dark),
            themeMode: ThemeMode.system,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              nostr_widgets.AppLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en'),
              Locale('es'),
              Locale('fr'),
              Locale('ja'),
            ],
            getPages: [
              GetPage(
                name: AppRoutes.todo,
                middlewares: [RouterIsLoggedInMiddleware()],
                page: () => HomePage(),
              ),
              GetPage(name: AppRoutes.signIn, page: () => SignInPage()),
              GetPage(
                name: AppRoutes.newTodo,
                middlewares: [RouterIsLoggedInMiddleware()],
                page: () => NewTodoPage(),
              ),
              GetPage(
                name: AppRoutes.user,
                middlewares: [RouterIsLoggedInMiddleware()],
                page: () => UserPage(),
              ),
              GetPage(
                name: AppRoutes.switchAccount,
                page: () => SwitchAccountPage(),
              ),
            ],
          ),
        );

        if (!kIsWeb && GetPlatform.isDesktop) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: DragToResizeArea(child: app),
          );
        }

        return app;
      },
    );
  }
}
