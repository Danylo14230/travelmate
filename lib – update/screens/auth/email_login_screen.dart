// lib/screens/auth/email_login_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();

  bool _isLoading = false;
  String? _authError;

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // перед запуском валідації очищаємо текст помилки
    setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService().signInWithEmail(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');

    } on FirebaseAuthException catch (e) {
      const wrong = [
        'wrong-password',
        'user-not-found',
        'invalid-email',
        'invalid-credential',
      ];

      setState(() {
        if (wrong.contains(e.code)) {
          _authError = 'Неправильний email або пароль';
        } else {
          _authError = e.message ?? 'Помилка входу';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Увійти через Email')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Вкажіть email';
                    }
                    final pattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!pattern.hasMatch(v.trim())) {
                      return 'Невірний email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passCtl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Вкажіть пароль';
                    }
                    return null;
                  },
                ),

                if (_authError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Увійти'),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: _goToRegister,
                  child: const Text('Немає акаунта? Зареєструватись'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
