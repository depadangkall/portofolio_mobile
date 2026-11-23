import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan riwayat edukasi.
///
/// Field mengikuti model `Education` di portofolio web: institusi, jenjang,
/// jurusan, tanggal mulai, tanggal selesai (opsional), dan IPK (opsional).
/// Data belum disimpan ke database; setelah validasi berhasil, isian
/// ditampilkan dalam [AlertDialog].
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// Batas panjang teks, disamakan dengan `max_length` pada model Django.
  static const int _maxTextLength = 100;

  static const List<String> _degrees = [
    'SMA/SMK',
    'D3',
    'S1',
    'S2',
    'S3',
  ];

  final _institutionController = TextEditingController();
  final _majorController = TextEditingController();
  final _gpaController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _degree = 'S1';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _institutionController.dispose();
    _majorController.dispose();
    _gpaController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Format tanggal sederhana `dd/mm/yyyy` tanpa package tambahan.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Membuka [showDatePicker] lalu menyimpan tanggal yang dipilih.
  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(DateTime.now().year + 10),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  /// Validator untuk teks wajib: tolak kosong, hanya spasi, atau terlalu panjang.
  String? _validateRequiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (value.trim().length > _maxTextLength) {
      return '$label maksimal $_maxTextLength karakter!';
    }
    return null;
  }

  /// IPK opsional, tetapi jika diisi harus angka antara 0.00 dan 4.00.
  String? _validateGpa(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final gpa = double.tryParse(value.trim().replaceAll(',', '.'));
    if (gpa == null) {
      return 'IPK harus berupa angka, misalnya 3.75';
    }
    if (gpa < 0 || gpa > 4) {
      return 'IPK harus berada di antara 0.00 dan 4.00';
    }
    return null;
  }

  /// Tanggal selesai opsional, tetapi tidak boleh sebelum tanggal mulai.
  String? _validateEndDate(String? _) {
    if (_endDate == null || _startDate == null) return null;
    if (_endDate!.isBefore(_startDate!)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai!';
    }
    return null;
  }

  InputDecoration _decoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    _institutionController.clear();
    _majorController.clear();
    _gpaController.clear();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _degree = 'S1';
      _startDate = null;
      _endDate = null;
    });
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final gpa = _gpaController.text.trim();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edukasi berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Institusi: ${_institutionController.text.trim()}'),
                Text('Jenjang: $_degree'),
                Text('Jurusan: ${_majorController.text.trim()}'),
                Text('Tanggal Mulai: ${_formatDate(_startDate!)}'),
                Text(
                  'Tanggal Selesai: '
                  '${_endDate == null ? 'Sekarang' : _formatDate(_endDate!)}',
                ),
                Text('IPK: ${gpa.isEmpty ? '-' : gpa}'),
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

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Education Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      // SafeArea + SingleChildScrollView menjaga semua input dan tombol
      // Simpan tetap bisa digulir saat layar sempit atau keyboard tampil.
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _institutionController,
                  textInputAction: TextInputAction.next,
                  maxLength: _maxTextLength,
                  decoration: _decoration(
                    'Nama Institusi',
                    hint: 'Contoh: Universitas Indonesia',
                  ),
                  validator: (v) => _validateRequiredText(v, 'Nama institusi'),
                ),
                const SizedBox(height: 12.0),
                DropdownButtonFormField<String>(
                  initialValue: _degree,
                  decoration: _decoration('Jenjang'),
                  items: _degrees
                      .map((degree) => DropdownMenuItem(
                            value: degree,
                            child: Text(degree),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _degree = value!),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _majorController,
                  textInputAction: TextInputAction.next,
                  maxLength: _maxTextLength,
                  decoration: _decoration(
                    'Jurusan / Program Studi',
                    hint: 'Contoh: Ilmu Komputer',
                  ),
                  validator: (v) => _validateRequiredText(v, 'Jurusan'),
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _decoration(
                    'Tanggal Mulai',
                    hint: 'Pilih tanggal',
                    icon: Icons.calendar_today,
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) =>
                      _startDate == null ? 'Tanggal mulai wajib diisi!' : null,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: _decoration(
                    'Tanggal Selesai (kosongkan jika masih berjalan)',
                    hint: 'Pilih tanggal',
                    icon: Icons.event,
                  ),
                  onTap: () => _pickDate(isStart: false),
                  validator: _validateEndDate,
                ),
                const SizedBox(height: 12.0),
                TextFormField(
                  controller: _gpaController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  decoration: _decoration('IPK (opsional)', hint: '0.00 - 4.00'),
                  validator: _validateGpa,
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                  ),
                  onPressed: _onSave,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
