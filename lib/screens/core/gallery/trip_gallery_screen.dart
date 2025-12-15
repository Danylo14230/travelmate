import 'package:flutter/material.dart';
import '../../../repositories/gallery_repository.dart';
import '../../../models/gallery_image.dart';

class TripGalleryScreen extends StatelessWidget {
  static const routeName = '/trip-gallery';
  const TripGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final repo = GalleryRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Галерея подорожі'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => repo.addPhoto(tripId),
          ),
        ],
      ),
      body: StreamBuilder<List<GalleryImage>>(
        stream: repo.photosStream(tripId),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Помилка: ${snap.error}'));
          }

          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snap.data!;
          if (images.isEmpty) {
            return const Center(child: Text('Немає фотографій'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1, // 🔥 усі плитки квадратні
            ),
            itemCount: images.length,
            itemBuilder: (_, i) {
              final img = images[i];

              return GestureDetector(
                onLongPress: () => _confirmDelete(context, repo, img),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.grey.shade200, // фон
                    alignment: Alignment.center,
                    child: Image.network(
                      img.url,
                      fit: BoxFit.contain, // 🔥 НЕ ОРІЖЕ
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context,
      GalleryRepository repo,
      GalleryImage img,
      ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити фото?'),
        content: const Text('Дію неможливо скасувати'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await repo.deletePhoto(img);
    }
  }
}
