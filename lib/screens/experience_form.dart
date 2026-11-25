import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan pengalaman baru ke backend Django.
///
/// Field mengikuti `ExperienceSerializer` (Tutorial 07): Title, Description,
/// Category, Thumbnail URL (opsional), dan Ended At (opsional). Saat Simpan
/// ditekan, data dikirim lewat `POST /api/v1/experiences/` dengan header
/// `Authorization: Token <key>`.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// Sama dengan `max_length` pada model Django.
  static const int _maxTitleLength = 255;
  static const int _maxThumbnailLength = 500;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _endedAtController = TextEditingController();

  String _category = 'full-time';
  DateTime? _endedAt;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _endedAtController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickEndedAt() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked == null) return;
    setState(() {
      // Disimpan sebagai UTC agar Django (USE_TZ=True) menerima datetime aware.
      _endedAt = DateTime.utc(picked.year, picked.month, picked.day);
      _endedAtController.text = _formatDate(picked);
    });
  }

  String? _validateRequired(String? value, String label, {int? maxLength}) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && value.trim().length > maxLength) {
      return '$label maksimal $maxLength karakter!';
    }
    return null;
  }

  /// Thumbnail opsional, tetapi jika diisi harus URL http/https yang valid.
  String? _validateThumbnail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (text.length > _maxThumbnailLength) {
      return 'URL maksimal $_maxThumbnailLength karakter!';
    }
    final uri = Uri.tryParse(text);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isValid ? null : 'Masukkan URL yang valid (http/https)!';
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _thumbnailController.clear();
    _endedAtController.clear();
    setState(() {
      _category = 'full-time';
      _endedAt = null;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Route guard: minta login dulu jika belum punya token.
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final token = context.read<AuthState>().token!;
    final newExperience = Experience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      thumbnail: _thumbnailController.text.trim(),
      endedAt: _endedAt,
    );

    final api = context.read<ApiClient>();
    setState(() => _isSubmitting = true);
    try {
      final created = await api.createExperience(newExperience, token: token);
      if (!mounted) return;
      // Matikan spinner sebelum dialog tampil (dialog tidak menutup halaman).
      setState(() => _isSubmitting = false);
      await _showSuccessDialog(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      if (e.statusCode == 401) {
        // Token kedaluwarsa/dicabut: buang token lalu minta login ulang.
        await context.read<AuthState>().logout();
        if (!mounted) return;
        _showSnackBar('Sesi berakhir, silakan login kembali.');
        await ensureLoggedIn(context);
      } else if (e.statusCode == 403) {
        _showSnackBar('Akun ini tidak punya izin menambah pengalaman.');
      } else {
        _showSnackBar('Gagal menyimpan (status ${e.statusCode}).');
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessDialog(Experience created) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pengalaman berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title: ${created.title}'),
                Text('Description: ${created.description}'),
                Text(
                  'Category: ${created.categoryDisplay.isEmpty ? created.category : created.categoryDisplay}',
                ),
                Text(
                  'Thumbnail: ${created.thumbnail.isEmpty ? '-' : created.thumbnail}',
                ),
                Text(
                  'Ended At: ${created.endedAt == null ? 'Ongoing' : _formatDate(created.endedAt!.toLocal())}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: _maxTitleLength,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('Title', hint: 'Contoh: COMPFEST'),
                  validator: (v) =>
                      _validateRequired(v, 'Title', maxLength: _maxTitleLength),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _decoration('Description'),
                  validator: (v) => _validateRequired(v, 'Description'),
                ),
                const SizedBox(height: 12.0),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _decoration('Category'),
                  items: Experience.categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _thumbnailController,
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    'Thumbnail URL (Optional)',
                    hint: 'https://...',
                  ),
                  validator: _validateThumbnail,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _endedAtController,
                  readOnly: true,
                  decoration: _decoration(
                    'Ended At (kosongkan jika masih berjalan)',
                    hint: 'Pilih tanggal',
                    icon: Icons.event,
                  ),
                  onTap: _pickEndedAt,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
