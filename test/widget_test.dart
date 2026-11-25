import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

const _experienceJson = {
  'id': '7f1c2c1e-0000-4000-8000-000000000001',
  'title': 'COMPFEST',
  'description': 'Marketing staff',
  'category': 'volunteer',
  'category_display': 'Volunteer',
  'thumbnail': null,
  'ended_at': null,
  'is_ongoing': true,
  'star_count': 2,
  'is_starred': false,
  'starred_by_names': '',
};

/// Backend palsu: mencatat request terakhir dan membalas seperti DRF.
class FakeBackend {
  http.Request? lastPost;
  int createStatus = 201;

  late final MockClient client = MockClient((request) async {
    final path = request.url.path;
    if (request.method == 'GET' && path == '/api/v1/experiences/') {
      return http.Response(jsonEncode([_experienceJson]), 200);
    }
    if (request.method == 'POST' && path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == 'secret') {
        return http.Response(jsonEncode({'token': 'abc123'}), 200);
      }
      return http.Response('{"non_field_errors": ["bad"]}', 400);
    }
    if (request.method == 'POST' && path == '/api/v1/experiences/') {
      lastPost = request;
      if (createStatus != 201) {
        return http.Response('{"detail": "Invalid token."}', createStatus);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          ..._experienceJson,
          ...body,
          'category_display': 'Internship',
        }),
        201,
      );
    }
    if (request.method == 'POST' && path == '/api/v1/auth/logout/') {
      return http.Response('', 204);
    }
    return http.Response('not found', 404);
  });

  ApiClient get api => ApiClient(client: client, baseUrl: 'http://test');
}

/// Membungkus [child] dengan provider yang sama seperti [MyApp].
Widget _withProviders(ApiClient api, Widget child, {String? token}) {
  return MultiProvider(
    providers: [
      Provider.value(value: api),
      ChangeNotifierProvider(
        create: (_) => AuthState(api, initialToken: token),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open navigation menu'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeBackend backend;

  setUp(() => backend = FakeBackend());

  testWidgets('Halaman utama menampilkan identitas dan tombol aksi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.api));

    expect(find.text('2506622481'), findsOneWidget);
    expect(find.text('I Gede Devadatta'), findsOneWidget);
    expect(find.text('PBP A'), findsOneWidget);

    expect(find.text('Lihat Pengalaman'), findsOneWidget);
    expect(find.text('Tambah Pengalaman'), findsOneWidget);
    expect(find.text('Tambah Edukasi'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Daftar pengalaman diambil dari API tanpa login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.api));

    await tester.tap(find.text('Lihat Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.text('COMPFEST'), findsOneWidget);

    await tester.tap(find.text('COMPFEST'));
    await tester.pumpAndSettle();
    expect(find.text('Marketing staff'), findsOneWidget);
    expect(find.text('Ongoing'), findsOneWidget);
    // Thumbnail kosong, jadi tidak ada widget gambar.
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('Tambah Pengalaman saat belum login membuka halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.api));

    await tester.tap(find.text('Tambah Pengalaman'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);

    // Field kosong ditolak.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Username cannot be empty!'), findsOneWidget);

    // Password salah -> SnackBar, tetap di halaman login.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'wrong',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Username atau password salah.'), findsOneWidget);

    // Password benar -> lanjut ke form.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Experience Form'), findsOneWidget);
  });

  testWidgets('Drawer menampilkan Login lalu Logout sesuai state', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await _openDrawer(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Experiences'), findsOneWidget);
    expect(find.text('Add Experience'), findsOneWidget);
    expect(find.text('Add Education'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Login'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Login'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Username'),
      'owner',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();

    await _openDrawer(tester);
    expect(find.widgetWithText(ListTile, 'Logout'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Berhasil logout.'), findsOneWidget);
  });

  testWidgets('Kartu Logout saat belum login menampilkan SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.api));
    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pump();
    expect(find.text('Kamu belum login.'), findsOneWidget);
  });

  testWidgets('Form pengalaman memvalidasi lalu POST dengan token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _withProviders(backend.api, const ExperienceFormPage(), token: 'abc123'),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), '   ');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Thumbnail URL (Optional)'),
      'bukan-url',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Description tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Masukkan URL yang valid (http/https)!'), findsOneWidget);
    expect(backend.lastPost, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Asdos PBP',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Teaching',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Thumbnail URL (Optional)'),
      '',
    );
    await tester.tap(find.text('Full-Time'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Internship').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final post = backend.lastPost!;
    expect(post.headers['Authorization'], 'Token abc123');
    final body = jsonDecode(post.body) as Map<String, dynamic>;
    expect(body['title'], 'Asdos PBP');
    expect(body['category'], 'internship');
    expect(body.containsKey('id'), isFalse);
    expect(body.containsKey('star_count'), isFalse);

    expect(find.text('Pengalaman berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Title: Asdos PBP'), findsOneWidget);
    expect(find.text('Category: Internship'), findsOneWidget);
  });

  testWidgets('Token tidak valid (401) membuat pengguna login ulang', (
    WidgetTester tester,
  ) async {
    backend.createStatus = 401;
    await tester.pumpWidget(
      _withProviders(backend.api, const ExperienceFormPage(), token: 'expired'),
    );

    await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'X');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Description'),
      'Y',
    );
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Login'), findsOneWidget);
  });

  testWidgets('Kartu Tambah Edukasi membuka form dan bisa kembali', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.api));

    await tester.tap(find.text('Tambah Edukasi'));
    await tester.pumpAndSettle();
    expect(find.text('Add Education Form'), findsOneWidget);

    // Dibuka dengan Navigator.push(), jadi tombol kembali bawaan perangkat
    // (disimulasikan lewat handlePopRoute) membawa pengguna ke halaman utama.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets('Drawer membuka form edukasi dan Home kembali ke halaman utama', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(MyApp(apiClient: backend.api));

    await _openDrawer(tester);
    await tester.tap(find.text('Add Education'));
    await tester.pumpAndSettle();
    expect(find.text('Add Education Form'), findsOneWidget);

    await _openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Selamat datang di MyPortfolio Mobile!'), findsOneWidget);
  });

  testWidgets(
    'Form edukasi menolak input tidak valid lalu menampilkan dialog',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        _withProviders(backend.api, const EducationFormPage()),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'),
        '   ',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'IPK (opsional)'),
        '4.5',
      );
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Jurusan tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Tanggal mulai wajib diisi!'), findsOneWidget);
      expect(
        find.text('IPK harus berada di antara 0.00 dan 4.00'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Institusi'),
        'Universitas Indonesia',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Jurusan / Program Studi'),
        'Ilmu Komputer',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'IPK (opsional)'),
        '3.80',
      );

      await tester.tap(find.widgetWithText(TextFormField, 'Tanggal Mulai'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Edukasi berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
      expect(find.text('IPK: 3.80'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    },
  );
}
