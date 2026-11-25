import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/experience_form.dart';
import 'package:myportofolio_mobile/screens/experience_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Drawer menu yang sama untuk semua halaman.
///
/// Opsi Login/Logout berubah otomatis mengikuti [AuthState] karena state
/// dibaca dengan `context.watch`.
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  void _replaceWith(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;

    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Portfolio',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore personal projects and experiences!',
                  style: TextStyle(fontSize: 15, color: Colors.white),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => _replaceWith(context, const MyHomePage()),
          ),
          ListTile(
            leading: const Icon(Icons.work_outline),
            title: const Text('Experiences'),
            onTap: () => _replaceWith(context, const ExperienceListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Experience'),
            // Hanya pengguna yang sudah login yang boleh membuka form.
            onTap: () async {
              if (!await ensureLoggedIn(context)) return;
              if (!context.mounted) return;
              _replaceWith(context, const ExperienceFormPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () => _replaceWith(context, const EducationFormPage()),
          ),
          const Divider(),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                // Ambil referensi sebelum drawer ditutup (context ikut hilang).
                final messenger = ScaffoldMessenger.of(context);
                final auth = context.read<AuthState>();
                Navigator.pop(context);
                await auth.logout();
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Berhasil logout.')),
                  );
              },
            ),
        ],
      ),
    );
  }
}
