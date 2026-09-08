import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/app_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const EyeCareAIApp(),
    ),
  );
}

class EyeCareAIApp extends StatelessWidget {
  const EyeCareAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return MaterialApp(
          title: 'VisionAI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightTheme(),
          darkTheme: AppTheme.getDarkTheme(),
          themeMode: ThemeMode.light, // Enforce light premium theme globally
          locale: appState.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('ur', ''),
          ],
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(appState.textScaleFactor),
                highContrast: appState.highContrast,
              ),
              child: widget ?? const SizedBox(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
