# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi milik **I Gede Devadatta** (NPM 2506622481, PBP A).
Proyek ini adalah bagian dari Proyek Individu mata kuliah Pemrograman Berbasis Platform (PBP) Fasilkom UI, Gasal 2026/2027, dan terpisah dari repositori Django.

## Fitur

- Tiga `InfoCard` di bagian atas berisi NPM, nama, dan kelas.
- Tiga tombol aksi (`ItemCard`) dengan warna latar berbeda:
  - **Lihat Proyek** (biru)
  - **Tambah Proyek** (hijau)
  - **Logout** (merah)
- Menekan tombol menampilkan `SnackBar`: *"Kamu telah menekan tombol [Nama Tombol]!"*

## Struktur Proyek

```
lib/
├── main.dart                 # Titik masuk aplikasi, MaterialApp + tema
├── menu.dart                 # MyHomePage (StatelessWidget), halaman utama
├── models/
│   └── item_homepage.dart    # Model ItemHomepage (name, icon, color)
└── widgets/
    ├── info_card.dart        # Kartu informasi profil
    └── item_card.dart        # Kartu tombol aksi + SnackBar
test/
└── widget_test.dart          # Widget test halaman utama dan SnackBar
```

## Cara Menjalankan

Prasyarat: [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang dan `flutter doctor` tidak melaporkan masalah untuk target yang dipakai.

```bash
git clone https://github.com/depadangkall/portofolio_mobile.git
cd portofolio_mobile
flutter pub get
flutter run            # pilih device: emulator, HP, Chrome, atau Windows
```

Pemeriksaan kualitas kode:

```bash
flutter analyze        # hasil: No issues found!
flutter test           # menjalankan widget test
```

## Progres Mingguan

| Minggu | Tugas | Isi |
|---|---|---|
| Tutorial 08 | Basic Flutter | Setup proyek, pemisahan `menu.dart`, `MyHomePage` jadi `StatelessWidget`, `InfoCard` & `ItemCard` |
| Tugas 7 | Basic Flutter | Warna unik per tombol lewat atribut `color` di `ItemHomepage`, pemisahan widget ke `lib/widgets/` dan model ke `lib/models/`, widget test, README |
