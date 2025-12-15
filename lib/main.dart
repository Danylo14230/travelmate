import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'env/env.dart';
import 'theme.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/core/main_layout.dart';

// Providers
import 'providers/trip_provider.dart';
import 'providers/expenses_provider.dart';
import 'providers/route_provider.dart';
import 'providers/tasks_provider.dart';
import 'providers/gallery_provider.dart';

late AppEnv appEnv;

Future<void> runAppWithEnv(AppEnv env) async {
  appEnv = env;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: appEnv.supabaseUrl,
    anonKey: appEnv.supabaseAnonKey,
  );

  if (appEnv.enableCrashlytics) {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
      ],
      child: const TravelMateApp(),
    ),
  );
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        MainLayout.routeName: (_) => const MainLayout(),
      },
    );
  }
}
