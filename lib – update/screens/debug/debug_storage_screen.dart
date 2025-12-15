import 'package:flutter/material.dart';
import '../../services/debug_storage.dart';
import '../../services/local_storage.dart';

class DebugStorageScreen extends StatelessWidget {
  const DebugStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEBUG STORAGE')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await DebugStorage.dumpAll();
              },
              child: const Text('📦 Dump SharedPreferences'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await LocalStorage.clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prefs cleared')),
                );
              },
              child: const Text('🔥 CLEAR ALL'),
            ),
          ],
        ),
      ),
    );
  }
}
