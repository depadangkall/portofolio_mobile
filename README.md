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

## Pertanyaan Reflektif

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, seluruh tampilan disusun dari widget, dan widget-widget itu tersusun bertingkat membentuk pohon (*widget tree*). Setiap widget bisa punya satu anak (`child`) atau banyak anak (`children`). Widget induk (*parent*) menentukan konteks bagi anaknya: posisi, batas ukuran (*constraints*), tema, dan data yang diwariskan. Prinsip layout Flutter adalah *"constraints go down, sizes go up, parent sets position"*: induk memberi batas ukuran ke anak, anak memilih ukurannya dalam batas itu, lalu induk menempatkan anak.

   Di aplikasi ini pohonnya kira-kira: `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → (`AppBar`, `Padding` → `Column` → (`Row` → 3× `InfoCard`, `GridView` → 3× `ItemCard`)). Contohnya, `GridView.count` (induk) membagi ruang menjadi 3 kolom, dan setiap `ItemCard` (anak) mengisi satu sel.

2. **Widget yang digunakan beserta fungsinya**

   | Widget | Fungsi |
   |---|---|
   | `MaterialApp` | Root aplikasi; mengatur judul, tema, dan halaman awal (`home`) |
   | `ThemeData` / `ColorScheme.fromSeed` | Mendefinisikan tema dan skema warna aplikasi *(objek konfigurasi, bukan widget)* |
   | `StatelessWidget` | Kelas dasar untuk `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard` |
   | `Scaffold` | Kerangka halaman Material: menyediakan slot `appBar` dan `body`, serta tempat SnackBar muncul |
   | `AppBar` | Bilah judul di bagian atas berisi teks "MyPortfolio" |
   | `Text` | Menampilkan teks (judul, isi kartu, nama tombol) |
   | `Padding` | Memberi jarak di sekeliling widget anaknya |
   | `Column` | Menyusun anak-anaknya secara vertikal |
   | `Row` | Menyusun tiga `InfoCard` secara horizontal |
   | `SizedBox` | Memberi jarak kosong dengan ukuran tetap |
   | `Center` | Menempatkan anak di tengah |
   | `Card` | Kotak bergaya Material dengan bayangan (`elevation`), dipakai `InfoCard` |
   | `Container` | Mengatur lebar dan padding isi kartu |
   | `GridView.count` | Menyusun `ItemCard` dalam grid 3 kolom |
   | `Material` | Memberi warna latar (`item.color`) dan sudut membulat pada `ItemCard`, sekaligus jadi permukaan efek ripple |
   | `InkWell` | Membuat area bisa ditekan (`onTap`) dengan efek ripple |
   | `Icon` | Menampilkan ikon tombol (`Icons.folder`, `Icons.add_circle`, `Icons.logout`) |
   | `ScaffoldMessenger` | Mengelola tampilan SnackBar di dalam `Scaffold` |
   | `SnackBar` | Pesan singkat di bawah layar saat tombol ditekan |

3. **Fungsi `MaterialApp` dan alasan dijadikan root widget**

   `MaterialApp` adalah widget pembungkus aplikasi bergaya Material Design. Widget ini menyiapkan banyak hal yang dibutuhkan widget di bawahnya: tema (`ThemeData`) yang bisa diakses lewat `Theme.of(context)`, sistem navigasi (`Navigator` dan routes), lokalisasi, arah teks, `MediaQuery`, dan `ScaffoldMessenger` untuk SnackBar. Karena semua layanan ini disediakan lewat *inherited widget* yang hanya bisa diakses oleh widget turunannya, `MaterialApp` perlu diletakkan paling atas agar seluruh halaman bisa memakainya. Contohnya, `ItemCard` di proyek ini bisa memanggil `ScaffoldMessenger.of(context)` dan `MyHomePage` bisa memakai `Theme.of(context).colorScheme.primary` karena keduanya berada di bawah `MaterialApp`.

4. **`StatelessWidget` vs `StatefulWidget`**

   - **`StatelessWidget`** tidak punya state internal yang berubah. Tampilannya hanya bergantung pada parameter konstruktor (yang bersifat `final`) dan data dari `context`. Widget ini hanya di-*build* ulang jika induknya membangunnya kembali dengan parameter baru.
   - **`StatefulWidget`** memiliki objek `State` terpisah yang bertahan selama widget ada di tree. Saat data di dalamnya berubah, kita memanggil `setState()` dan Flutter memanggil ulang `build()` untuk memperbarui tampilan.

   Pilih **`StatelessWidget`** jika tampilan hanya bergantung pada input yang tidak berubah, misalnya `InfoCard` yang menampilkan NPM/nama/kelas, atau `ItemCard` yang hanya menampilkan ikon dan teks. Pilih **`StatefulWidget`** jika widget harus mengingat dan bereaksi terhadap perubahan data seiring waktu, misalnya counter, form input, checkbox, animasi, atau data yang diambil dari internet. Di proyek ini semua widget cukup stateless karena SnackBar dikelola oleh `ScaffoldMessenger`, bukan oleh state milik widget kita.

5. **`BuildContext`**

   `BuildContext` adalah "alamat" atau posisi sebuah widget di dalam widget tree (secara teknis, ia adalah `Element` milik widget tersebut). Lewat `context`, widget bisa mencari widget leluhurnya ke atas pohon dan mengakses data yang disediakan leluhur tersebut. Ini penting karena data seperti tema, ukuran layar, navigasi, dan SnackBar diwariskan dari atas dan hanya bisa diambil lewat `context`.

   Di metode `build(BuildContext context)`, Flutter memberikan `context` milik widget itu sendiri. Contoh penggunaannya di proyek ini:
   - `Theme.of(context).colorScheme.primary` untuk warna AppBar di `MyHomePage`.
   - `MediaQuery.of(context).size.width` untuk menghitung lebar `InfoCard`.
   - `ScaffoldMessenger.of(context).showSnackBar(...)` di `ItemCard` untuk menampilkan SnackBar.

   Karena pencarian dilakukan ke atas mulai dari posisi `context`, kita harus memakai `context` yang memang berada di bawah widget yang dicari. Contohnya, `ScaffoldMessenger.of(context)` akan gagal jika dipanggil dengan `context` yang berada di atas `MaterialApp`.

6. **Hot reload vs hot restart**

   - **Hot reload** (`r` di terminal / ikon petir) menyuntikkan kode Dart yang berubah ke Dart VM yang sedang berjalan, lalu Flutter mem-*build* ulang widget tree. **State aplikasi tetap dipertahankan**, misalnya nilai counter atau halaman yang sedang dibuka, sehingga sangat cepat untuk mengubah tampilan.
   - **Hot restart** (`R`) memuat ulang seluruh kode dan **menjalankan aplikasi dari awal** (`main()` dipanggil lagi), sehingga semua state hilang. Prosesnya lebih lambat dari hot reload, tetapi masih lebih cepat daripada full restart karena tidak perlu kompilasi ulang native.
   - **Full restart** (stop lalu `flutter run` lagi) membangun ulang aplikasi sepenuhnya, termasuk bagian native.

   Hot reload tidak cukup dan kita perlu **hot restart** saat:
   - Mengubah kode di `main()` atau `initState()`, karena keduanya tidak dijalankan ulang oleh hot reload.
   - Mengubah inisialisasi variabel global atau `static` (nilainya sudah terinisialisasi sebelumnya).
   - Mengubah tipe sebuah class, misalnya `StatelessWidget` menjadi `StatefulWidget`, atau mengubah enum dan tipe generik.

   Kita perlu **full restart** saat:
   - Menambah atau memperbarui package/plugin di `pubspec.yaml` yang punya kode native.
   - Mengubah kode native (Android/iOS), aset tertentu, atau konfigurasi seperti `AndroidManifest.xml`.
