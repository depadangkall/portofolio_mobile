import 'package:flutter/material.dart';

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Setiap item menyimpan [name] (teks tombol), [icon], dan [color]
/// (warna latar kartu), sehingga [ItemCard] tidak perlu percabangan
/// `if-else` untuk menentukan warna masing-masing tombol.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
