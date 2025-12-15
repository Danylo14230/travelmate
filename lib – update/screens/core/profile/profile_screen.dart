import 'package:flutter/material.dart';

import '../../../widgets/section_card.dart';
import '../../../widgets/user_avatar.dart';
import '../../../widgets/app_button.dart';

// 🔥 DEBUG SCREEN
//import '../../debug/debug_storage_screen.dart';

class ProfileScreen extends StatelessWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

  void _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вийти з акаунта?'),
        content: const Text('Ви справді хочете вийти з акаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Navigator.of(context, rootNavigator: true)
          .pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [

            // 🔹 АКАУНТ
            SectionCard(
              title: 'Акаунт',
              child: Column(
                children: [
                  const UserAvatar(initials: 'О', radius: 42),
                  const SizedBox(height: 12),
                  const Text(
                    'Олена Коваленко',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'olena@example.com',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppButton(
                        label: 'Редагувати',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Редагування у розробці')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        label: 'Підтримка',
                        outlined: true,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Підтримка у розробці')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 НАЛАШТУВАННЯ
            SectionCard(
              title: 'Налаштування',
              icon: Icons.settings,
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.language),
                    title: Text('Мова'),
                    subtitle: Text('Українська'),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Сповіщення'),
                    subtitle: Text('Увімкнено'),
                  ),
                ],
              ),
            ),

            // 🔹 ПРО ДОДАТОК
            SectionCard(
              title: 'Про додаток',
              icon: Icons.info_outline,
              child: Column(
                children: [

                  const ListTile(
                    leading: Icon(Icons.star),
                    title: Text('Оцінити додаток'),
                  ),
/*
                  // 🔥 DEBUG STORAGE BUTTON
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: const Text('DEBUG STORAGE'),
                    subtitle: const Text('SharedPreferences / JSON'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DebugStorageScreen(),
                        ),
                      );
                    },
                  ),
*/
                  // 🚪 LOGOUT
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Вийти з акаунта'),
                    onTap: () => _logout(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
