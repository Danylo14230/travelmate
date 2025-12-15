import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();

  bool _accepted = false;
  bool _isLoading = false;

  String? _authError; // 🔥 тепер всі помилки через GlobalKey & локальну змінну

  @override
  void dispose() {
    _nameCtl.dispose();
    _emailCtl.dispose();
    _passCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    if (!_accepted) {
      setState(() => _authError = 'Потрібно прийняти умови використання');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().registerWithEmail(
        email: _emailCtl.text.trim(),
        password: _passCtl.text.trim(),
        displayName: _nameCtl.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed('/main');

    } on FirebaseAuthException catch (e) {
      setState(() => _authError = e.message ?? 'Помилка реєстрації');
    } catch (e) {
      setState(() => _authError = 'Помилка: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameCtl,
                  decoration: const InputDecoration(labelText: 'Імʼя та прізвище'),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Вкажіть імʼя' : null,
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _emailCtl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Вкажіть email';
                    }
                    final pattern = RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    );
                    if (!pattern.hasMatch(v.trim())) {
                      return 'Невірний формат email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passCtl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Вкажіть пароль';

                    final pass = v.trim();

                    if (pass.length < 8) return 'Пароль має бути мінімум 8 символів';
                    if (!RegExp(r'[A-Z]').hasMatch(pass)) return 'Додайте велику літеру';
                    if (!RegExp(r'[a-z]').hasMatch(pass)) return 'Додайте малу літеру';
                    if (!RegExp(r'\d').hasMatch(pass)) return 'Додайте цифру';
                    if (!RegExp(r'[!@#\$%\^&\*(),.?":{}|<>]').hasMatch(pass)) {
                      return 'Додайте спецсимвол';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _confirmCtl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Підтвердіть пароль'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Підтвердіть пароль';
                    }
                    if (v.trim() != _passCtl.text.trim()) {
                      return 'Паролі не співпадають';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                CheckboxListTile(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v ?? false),
                  title: const Text('Погоджуюсь з умовами використання'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                /// 🔥 ПОКАЗ ГЛОБАЛЬНИХ ПОМИЛОК
                if (_authError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Зареєструватись'),
                  ),
                ),

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Повернутись до входу'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
