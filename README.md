# MyPortfolio Mobile

Aplikasi Flutter portofolio pribadi **I Gede Devadatta** (2506622481, PBP A). Menampilkan kartu NPM/nama/kelas, tombol aksi berwarna, dan drawer navigasi. Data pengalaman diambil dari backend Django REST Framework ([myportofolio](https://i-gede57-myportofolio.pws.cs.ui.ac.id)) lewat `/api/v1/experiences/`; menambah pengalaman butuh login dengan token. Ada juga formulir Tambah Edukasi (lokal) dengan validasi dan dialog ringkasan.

## Cara Menjalankan

```bash
git clone https://github.com/depadangkall/portofolio_mobile.git
cd portofolio_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generate *.g.dart

# Backend Django lokal harus jalan dulu (python manage.py runserver)
flutter run                                                          # emulator Android (http://10.0.2.2:8000)
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000  # Chrome

flutter analyze && flutter test   # cek kode & test (API di-mock, tidak butuh server)
```

CI/CD ada di `.github/workflows/main.yaml`: job `build` (format, analyze, test) lalu `build_apk` yang mengunggah artefak `app-release-apk`. Set repository variable `API_BASE_URL` di GitHub agar APK mengarah ke backend yang sudah di-deploy.

## Progres Mingguan

| Minggu | Isi |
|---|---|
| Tutorial 08 | Setup proyek, `menu.dart`, `MyHomePage` stateless, `InfoCard` & `ItemCard` |
| Tugas 7 | Warna unik per tombol (`ItemHomepage.color`), widget & model dipisah ke `lib/widgets/` & `lib/models/`, widget test |
| Tutorial 09 | `LeftDrawer` (Home / Add Project), `ProjectFormPage` dengan validasi & pop-up hasil, tombol Tambah Proyek → form, refactor ke `lib/screens/` & `lib/widgets/project_card.dart`, impor `material_ui` |
| Tugas 8 | `EducationFormPage` (`lib/screens/education_form.dart`): institusi, jenjang, jurusan, tanggal mulai/selesai (`showDatePicker`), IPK; validasi kosong/spasi, panjang maks, rentang IPK, urutan tanggal; dialog ringkasan; kartu **Tambah Edukasi** + opsi **Add Education** di drawer; halaman utama bisa di-scroll; widget test baru |

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

### Tugas 8

1. **`Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`**

   `Navigator` mengelola halaman sebagai *stack* (tumpukan route).
   - `Navigator.push()` menaruh route baru **di atas** route sekarang. Halaman lama tetap ada di bawahnya, jadi pengguna bisa kembali dengan tombol back.
   - `Navigator.pushReplacement()` **mengganti** route paling atas dengan route baru. Halaman lama dibuang dari stack, jadi tombol back tidak kembali ke sana.
   - `Navigator.pop()` **menghapus** route paling atas sehingga pengguna kembali ke route di bawahnya. Di proyek ini `pop()` juga dipakai untuk menutup `AlertDialog`, karena dialog juga sebuah route.

   Kartu **Tambah Edukasi** di halaman utama memakai `Navigator.push()` (di `lib/widgets/project_card.dart`), sehingga stack menjadi `[MyHomePage, EducationFormPage]` dan tombol back bawaan perangkat membawa pengguna kembali ke halaman utama. Opsi **Home** di `LeftDrawer` memakai `Navigator.pushReplacement()` dengan `MyHomePage` sebagai route baru: halaman formulir yang sedang terbuka diganti oleh halaman utama, jadi stack tidak terus menumpuk setiap kali pengguna berpindah lewat drawer. Ini juga cara yang mudah untuk kembali ke halaman utama saat aplikasi dijalankan di Chrome.

2. **Konsistensi dengan `Scaffold`, `AppBar`, dan `Drawer`**

   `Scaffold` menyediakan kerangka yang sama untuk setiap halaman: slot `appBar` di atas, `drawer` di kiri, dan `body` di tengah. Karena halaman utama, form proyek, dan form edukasi memakai susunan yang sama, pengguna selalu menemukan judul di tempat yang sama dan ikon menu (hamburger) di pojok kiri atas. `LeftDrawer` ditulis sekali di `lib/widgets/left_drawer.dart` lalu dipakai (`drawer: const LeftDrawer()`) di ketiga halaman, sehingga menambah opsi baru seperti **Add Education** cukup dilakukan di satu tempat.

   Contoh warna tema: `MaterialApp` di `main.dart` memakai `ColorScheme.fromSeed(seedColor: Colors.indigo)`. Warna `Theme.of(context).colorScheme.primary` dipakai untuk latar `AppBar` di `MyHomePage` dan juga untuk `AppBar` serta tombol **Simpan** di `EducationFormPage`, sementara `DrawerHeader` memakai indigo. Jadi semua halaman memakai keluarga warna indigo yang sama, dan jika seed warna diubah, AppBar kedua halaman ikut berubah.

3. **Tata letak formulir, widget pengatur jarak, dan widget penggulir**

   Formulir disusun sebagai satu kolom vertikal (`Column` dengan `crossAxisAlignment: CrossAxisAlignment.stretch`): satu input per baris dengan lebar penuh, lalu tombol **Simpan** di paling bawah. Susunan ini paling mudah dibaca di layar ponsel yang sempit, urutan pengisiannya jelas dari atas ke bawah, dan label serta pesan error setiap kolom punya ruang yang cukup.

   - **Widget pengatur jarak:** `SingleChildScrollView(padding: EdgeInsets.all(16))` memberi jarak dari tepi layar, dan `SizedBox(height: 12)` di antara input (serta `SizedBox(height: 24)` sebelum tombol) memberi jarak yang seragam sehingga kolom tidak saling menempel dan pesan error tidak menabrak kolom berikutnya.
   - **Widget penggulir:** `SingleChildScrollView` membuat seluruh isi form bisa digulir. Saat keyboard muncul, `Scaffold` mengecilkan area `body`; tanpa penggulir, `Column` akan *overflow* (garis kuning-hitam) dan tombol **Simpan** bisa tertutup keyboard. Dengan penggulir, semua input dan tombol tetap bisa dijangkau. `SafeArea` menjaga isi tidak tertutup notch atau status bar. Halaman utama juga dibungkus `SingleChildScrollView` agar grid kartu aksi (sekarang dua baris) tidak meluap di layar pendek.

4. **`GlobalKey<FormState>`, `validator`, dan `validate()`**

   - `GlobalKey<FormState>` (`_formKey`) dipasang di widget `Form` sehingga kita bisa mengakses state form dari luar widget tree-nya, misalnya dari `onPressed` tombol **Simpan** lewat `_formKey.currentState`.
   - `validator` adalah fungsi di setiap `TextFormField` yang menerima nilai input dan mengembalikan `null` jika valid, atau `String` pesan error jika tidak valid.
   - `validate()` dipanggil saat **Simpan** ditekan. Method ini menjalankan semua `validator` di dalam `Form`, menampilkan pesan error di bawah kolom yang bermasalah, lalu mengembalikan `true` hanya jika semuanya valid. Dialog ringkasan hanya ditampilkan jika hasilnya `true`.

   Contoh nilai yang ditolak: kolom **IPK** diisi `4.5`. Kolom ini memakai `keyboardType: TextInputType.numberWithOptions(decimal: true)`, sehingga di ponsel yang muncul adalah keyboard angka, tetapi keyboard hanya membatasi *cara* mengetik, bukan *nilai* yang masuk akal. `4.5` adalah angka yang sah, tetapi di luar rentang IPK 0.00–4.00, jadi validator menolaknya dengan pesan *"IPK harus berada di antara 0.00 dan 4.00"*. Selain itu, keyboard angka tidak berlaku di Chrome/desktop, pengguna masih bisa menempelkan (*paste*) teks bebas, dan aturan seperti "tidak boleh hanya spasi" (`"   "` pada Nama Institusi), batas 100 karakter, atau "tanggal selesai tidak boleh sebelum tanggal mulai" sama sekali tidak bisa dijamin oleh jenis input. Karena itu validasi tetap diperlukan.

## AI Disclosure

**Tools yang dipakai:** Claude Code (model Claude Opus 5.5) di ekstensi VS Code, dengan akses ke folder proyek dan terminal.

**Strategi prompting:** Saya memberikan arahan kepada Claude untuk membaca kode hasil Tutorial 08 terlebih dahulu dan perintah dari tugas 7, lalu hanya mengubah bagian yang belum memenuhi checklist.

**Bagian yang dibantu AI:**
- Menambahkan atribut `color` ke `ItemHomepage` dan memakai `item.color` di `ItemCard` (warna biru, hijau, merah).
- Memindahkan `InfoCard`, `ItemCard`, dan `ItemHomepage` ke `lib/widgets/` dan `lib/models/`, serta menambahkan komentar/docstring.
- Mengganti test counter bawaan (yang gagal karena aplikasi sudah tidak punya counter) dengan widget test untuk halaman utama dan SnackBar.
- Menyusun README ini, termasuk draf jawaban pertanyaan reflektif.
- Membuat commit bertahap dengan format *conventional commits*.

**Verifikasi dan batasan:** Hasil AI diverifikasi dengan `flutter analyze` (*No issues found!*) dan `flutter test` (semua test lolos). AI tidak bisa melihat tampilan aplikasi secara langsung, jadi tampilan tetap saya cek sendiri dengan `flutter run`. Jawaban pertanyaan reflektif sudah saya baca ulang dan cocokkan dengan dokumentasi Flutter serta materi Tutorial 08 agar saya memahaminya sendiri.

### Tugas 8

**Strategi prompting:** Saya memberikan PDF soal Tugas 8 kepada Claude dan meminta Claude membaca kode hasil Tutorial 09 terlebih dahulu, lalu membuat formulir baru mengikuti pola `ProjectFormPage` dan drawer yang sudah ada, bekerja di branch `feat/tugas-8`.

**Bagian yang dibantu AI:**
- Membuat `lib/screens/education_form.dart` (field, validator, `showDatePicker`, dialog ringkasan).
- Menambahkan kartu **Tambah Edukasi** (`menu.dart`, `project_card.dart`) dan opsi **Add Education** di `left_drawer.dart`, serta membuat halaman utama bisa digulir.
- Menambahkan widget test untuk navigasi kartu/drawer dan validasi form edukasi.
- Menyusun draf jawaban pertanyaan reflektif Tugas 8.

**Keterbatasan AI dan perbaikan:** Test pertama buatan AI memakai `tester.pageBack()` untuk menguji tombol kembali dan gagal, karena halaman yang punya `drawer` menampilkan ikon hamburger, bukan panah kembali di `AppBar`. Test diperbaiki untuk mensimulasikan tombol back sistem (`handlePopRoute`), yang memang menjadi alur kembali dari kartu aksi. AI juga tidak bisa melihat tampilan secara langsung, sehingga tata letak di layar selebar ponsel (termasuk saat keyboard muncul) saya cek sendiri dengan `flutter run -d chrome`. Hasil akhir diverifikasi dengan `flutter analyze` (*No issues found!*) dan `flutter test` (8 test lolos).
