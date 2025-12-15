// lib/screens/auth/login_screen.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'email_login_screen.dart';
import '../auth/register_screen.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();       // 🔥 GlobalKey для помилок
  String? _error;                                // 🔥 глобальна помилка (анонімний/Google/Apple)

  void _openEmail(BuildContext ctx) {
    Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => const EmailLoginScreen()));
  }

  Future<void> _guest(BuildContext ctx) async {
    setState(() => _error = null);

    try {
      final userCred = await AuthService().signInAnonymously();
      if (userCred.user != null) {
        Navigator.of(ctx).pushReplacementNamed('/main');
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Помилка анонімного входу');
    } catch (e) {
      setState(() => _error = 'Помилка: ${e.toString()}');
    }
  }

  Future<void> _google(BuildContext ctx) async {
    setState(() => _error = null);

    try {
      final userCred = await AuthService().signInWithGoogle();
      if (userCred.user != null) {
        Navigator.of(ctx).pushReplacementNamed('/main');
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Google Sign-In Error');
      setState(() => _error = 'Google Sign-In помилка: ${e.toString()}');
    }
  }

  Future<void> _apple(BuildContext ctx) async {
    setState(() => _error = null);

    try {
      final userCred = await AuthService().signInWithApple();
      if (userCred.user != null) {
        Navigator.of(ctx).pushReplacementNamed('/main');
        await FirebaseAnalytics.instance.logLogin(loginMethod: 'apple');
      }
    } catch (e) {
      setState(() => _error = 'Apple Sign-In помилка: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 360,
            height: 750,
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.hardEdge,
              child: Form(
                key: _formKey,     // 🔥 GlobalKey прив’язано до всієї auth-форми
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            /// *** NEW: Logo / Image ***
                            ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: Image.asset(
                                'assets/logo.png',
                                width: 256,
                                height: 256,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Ласкаво просимо',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                            ),

                            const SizedBox(height: 8),
                            const Text(
                              'Плануйте подорожі та діліться враженнями.',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),


                            /// EMAIL LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => _openEmail(context),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                child: const Text('Увійти через email'),
                              ),
                            ),

                            /// CRASH TEST
                            ElevatedButton(
                              onPressed: () {
                                FirebaseCrashlytics.instance.crash();
                              },
                              child: const Text('Test Crash'),
                            ),

                            const SizedBox(height: 12),

                            /// GOOGLE + APPLE
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Text('🔍'),
                                    label: const Text('Google'),
                                    onPressed: () => _google(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Text('🍎'),
                                    label: const Text('Apple'),
                                    onPressed: () => _apple(context),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            /// GUEST LOGIN
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () async {
                                  await _guest(context);
                                  await FirebaseAnalytics.instance.logEvent(name: 'guest_enter');
                                },
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: const BorderSide(color: Colors.blue),
                                ),
                                child: const Text('Пробний огляд'),
                              ),
                            ),

                            /// ❗ ПОКАЗ ПОМИЛОК ПІД ВСІМА КНОПКАМИ
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],

                            const SizedBox(height: 18),

                            /// REGISTER LINK
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Немає акаунта? ', style: TextStyle(color: Colors.black54)),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pushNamed(RegisterScreen.routeName),
                                  child: const Text('Зареєструватись',
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
