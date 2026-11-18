import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

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

  testWidgets('Tombol Tambah Proyek membuka halaman form',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Drawer berisi navigasi Home dan Add Project',
      (WidgetTester tester) async {
    // Font uji (Ahem) jauh lebih lebar dari font asli sehingga teks
    // DrawerHeader meluap; skala teks diperkecil hanya untuk test ini.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.text('Add Project Form'), findsOneWidget);
  });

  testWidgets('Form memvalidasi field wajib lalu menampilkan isian',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Proyek'), 'Burhanpedia');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Deskripsi Proyek'), 'Ensiklopedia');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: Burhanpedia'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
  });
}
