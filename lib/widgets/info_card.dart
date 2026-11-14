import 'package:flutter/material.dart';

/// Kartu kecil yang menampilkan satu informasi profil pemilik portofolio
/// (misalnya NPM, nama, atau kelas).
class InfoCard extends StatelessWidget {
  /// Label informasi, misalnya `'NPM'`.
  final String title;

  /// Isi informasi, misalnya `'2506622481'`.
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      child: Container(
        // Tiga kartu disusun dalam satu baris, jadi lebarnya ~1/3.5 layar.
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
