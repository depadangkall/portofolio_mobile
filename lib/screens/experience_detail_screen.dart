import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';

/// Halaman detail satu [Experience].
///
/// Gambar thumbnail hanya ditampilkan jika URL-nya tidak kosong.
class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({required this.experience, super.key});

  final Experience experience;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final endedAt = experience.endedAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          experience.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (experience.thumbnail.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  experience.thumbnail,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              experience.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    experience.categoryDisplay.isEmpty
                        ? experience.category
                        : experience.categoryDisplay,
                  ),
                ),
                Chip(
                  label: Text(
                    endedAt == null
                        ? 'Ongoing'
                        : 'Ended ${_formatDate(endedAt)}',
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: Text('${experience.starCount}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(experience.description),
          ],
        ),
      ),
    );
  }
}
