import 'package:donow/app_routes.dart';
import 'package:donow/config.dart';
import 'package:donow/database/database.dart';
import 'package:donow/get_database.dart';
import 'package:donow/middlewares/router_is_logged_in_middleware.dart';
import 'package:donow/no_event_verifier.dart';
import 'package:donow/repository.dart';
import 'package:donow/screens/new_todo/new_todo_page.dart';
import 'package:donow/screens/sign_in/sign_in_page.dart';
import 'package:donow/screens/todo/todo_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ndk/ndk.dart';
import 'package:system_theme/system_theme.dart';
import 'package:sembast_cache_manager/sembast_cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemTheme.accentColor.load();

  Get.put(AppDatabase());

  final ndk = Ndk(
    NdkConfig(
      eventVerifier: NoEventVerifier(),
      cache: SembastCacheManager(await getDatabase()),
    ),
  );
  Get.put(ndk);

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
        if (kIsWeb) accentColor = const Color(0xFFF81242);

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

        return GetMaterialApp(
          title: appTitle,
          theme: getTheme(),
          darkTheme: getTheme(Brightness.dark),
          themeMode: ThemeMode.system,
          getPages: [
            GetPage(
              name: AppRoutes.todo,
              middlewares: [RouterIsLoggedInMiddleware()],
              page: () => TodoPage(),
            ),
            GetPage(name: AppRoutes.signIn, page: () => SignInPage()),
            GetPage(
              name: AppRoutes.newTodo,
              middlewares: [RouterIsLoggedInMiddleware()],
              page: () => NewTodoPage(),
            ),
          ],
        );
      },
    );
  }
}
