import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
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
    expect(find.text('Tambah Edukasi'), findsOneWidget);
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

  testWidgets('Kartu Tambah Edukasi membuka form dan bisa kembali',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Edukasi'));
    await tester.pumpAndSettle();
    expect(find.text('Add Education Form'), findsOneWidget);

    // Dibuka dengan Navigator.push(), jadi tombol kembali bawaan perangkat
    // (disimulasikan lewat handlePopRoute) membawa pengguna ke halaman utama.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer membuka form edukasi dan Home kembali ke halaman utama',
      (WidgetTester tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();
    expect(find.text('Add Education Form'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Form edukasi menolak input tidak valid lalu menampilkan dialog',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

    // Isian kosong dan hanya spasi ditolak.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'), '   ');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'IPK (opsional)'), '4.5');
    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pump();
    expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Jurusan tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Tanggal mulai wajib diisi!'), findsOneWidget);
    expect(find.text('IPK harus berada di antara 0.00 dan 4.00'),
        findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'),
        'Universitas Indonesia');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Jurusan / Program Studi'),
        'Ilmu Komputer');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'IPK (opsional)'), '3.80');

    // Pilih tanggal mulai lewat showDatePicker().
    await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simpan'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Edukasi berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
    expect(find.text('Jurusan: Ilmu Komputer'), findsOneWidget);
    expect(find.text('IPK: 3.80'), findsOneWidget);
    expect(find.text('Tanggal Selesai: Sekarang'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Add Education Form'), findsOneWidget);
  });
}
