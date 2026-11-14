import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Halaman utama menampilkan identitas dan tombol aksi',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Tiga InfoCard berisi identitas pemilik.
    expect(find.text('2506622481'), findsOneWidget);
    expect(find.text('I Gede Devadatta'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);

    // Tiga tombol aksi.
    expect(find.text('Lihat Proyek'), findsOneWidget);
    expect(find.text('Tambah Proyek'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Menekan tombol menampilkan SnackBar yang sesuai',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Kamu telah menekan tombol Tambah Proyek!'),
        findsOneWidget);
  });
}
