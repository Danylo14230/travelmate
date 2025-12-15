import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'package:travel_organizer/providers/gallery_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'theme.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/core/main_layout.dart';

// Провайдери
import 'providers/route_provider.dart';
import 'providers/expenses_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/tasks_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Supabase.initialize(
    url: 'https://nthhhxrtvhtmiacycmam.supabase.co',
    anonKey: 'sb_secret_nBriGhBIYInUySb9oInUxQ_Q43cHSc3',
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  final analytics = FirebaseAnalytics.instance;

  print('🔍 Logging test event...');
  await analytics.logEvent(
    name: 'test_event',
    parameters: {'platform': 'web'},
  );
  print('✅ Test event logged!');

  runApp(const TravelMateApp());
}

class TravelMateApp extends StatelessWidget {
  const TravelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
        ChangeNotifierProvider(create: (_) => RouteProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),


      ],
      child: MaterialApp(
        title: 'TravelMate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: LoginScreen.routeName,
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          MainLayout.routeName: (_) => const MainLayout(),
        },
        onUnknownRoute: (_) =>
            MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
    );
  }
}
