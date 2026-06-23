import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LaporanFormScreen extends StatefulWidget {
  final Map? laporan; // null = tambah baru, isi = edit

  const LaporanFormScreen({super.key, this.laporan});

  @override
  State<LaporanFormScreen> createState() => _LaporanFormScreenState();
}

class _LaporanFormScreenState extends State<LaporanFormScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _kategori = 'Jalan';
  String _status = 'pending';
  bool _isLoading = false;
  bool get _isEdit => widget.laporan != null;

  final List<String> _kategoriList = [
    'Jalan',
    'Sampah',
    'Lampu',
    'Air',
    'Lainnya',
  ];
  final List<String> _statusList = ['pending', 'proses', 'selesai'];

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _judulController.text = widget.laporan!['judul'] ?? '';
      _deskripsiController.text = widget.laporan!['deskripsi'] ?? '';
      _kategori = widget.laporan!['kategori'] ?? 'Jalan';
      _status = widget.laporan!['status'] ?? 'pending';
    }
  }

  Future<void> _simpan() async {
    if (_judulController.text.isEmpty || _deskripsiController.text.isEmpty) {
      _showSnackbar('Judul dan deskripsi wajib diisi', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEdit) {
        await ApiService.updateLaporan(widget.laporan!['id'], {
          'judul': _judulController.text,
          'deskripsi': _deskripsiController.text,
          'kategori': _kategori,
          'status': _status,
        });
        _showSnackbar('Laporan berhasil diupdate');
      } else {
        await ApiService.createLaporan({
          'judul': _judulController.text,
          'deskripsi': _deskripsiController.text,
          'kategori': _kategori,
        });
        _showSnackbar('Laporan berhasil dibuat');
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showSnackbar('Gagal menyimpan laporan', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Laporan' : 'Buat Laporan',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Judul
            TextField(
              controller: _judulController,
              decoration: InputDecoration(
                labelText: 'Judul Laporan',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextField(
              controller: _deskripsiController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Kategori
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: const Icon(Icons.category_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _kategoriList
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),

            // Status (hanya tampil saat edit)
            if (_isEdit)
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  prefixIcon: const Icon(Icons.info_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _statusList
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            if (_isEdit) const SizedBox(height: 16),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEdit ? 'Update Laporan' : 'Kirim Laporan',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
