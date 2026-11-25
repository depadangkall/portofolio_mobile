import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/item_homepage.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Kartu tombol aksi pada halaman utama.
///
/// Warna latar diambil dari [ItemHomepage.color]. Saat ditekan:
/// - "Lihat Pengalaman" membuka [ExperienceListScreen] (publik),
/// - "Tambah Pengalaman" meminta login lewat [ensureLoggedIn] lalu membuka
///   [ExperienceFormPage],
/// - "Tambah Edukasi" membuka [EducationFormPage],
/// - "Logout" mencabut token lewat [AuthState.logout].
class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onTap(BuildContext context) async {
    switch (item.name) {
      case "Lihat Pengalaman":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceListScreen()),
        );
      case "Tambah Pengalaman":
        if (!await ensureLoggedIn(context)) return;
        if (!context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExperienceFormPage()),
        );
      case "Tambah Edukasi":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationFormPage()),
        );
      case "Logout":
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) {
          _showSnackBar(context, "Kamu belum login.");
          return;
        }
        await auth.logout();
        if (!context.mounted) return;
        _showSnackBar(context, "Berhasil logout.");
      default:
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
