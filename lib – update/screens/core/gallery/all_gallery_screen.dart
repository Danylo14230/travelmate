import 'package:flutter/material.dart';
import '../../../models/gallery_image.dart';
import '../../../repositories/gallery_repository.dart';

class AllGalleryScreen extends StatelessWidget {
  static const routeName = '/gallery';
  const AllGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = GalleryRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Галерея')),
      body: StreamBuilder<List<GalleryImage>>(
        stream: repo.allGallery(),
        builder: (_, snap) {
          if (snap.hasError) {
            return Center(child: Text('Помилка: ${snap.error}'));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snap.data!;
          if (images.isEmpty) {
            return const Center(child: Text('Галерея порожня'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // 🔥 квадратні плитки
            ),
            itemCount: images.length,
            itemBuilder: (_, i) {
              final img = images[i];

              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Colors.grey.shade200, // фон
                  alignment: Alignment.center,
                  child: Image.network(
                    img.url,
                    fit: BoxFit.contain, // 🔥 НЕ ОРІЗАЄ
                    loadingBuilder: (ctx, child, loading) {
                      if (loading == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
