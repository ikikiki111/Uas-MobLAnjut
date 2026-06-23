import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'laporan_form_screen.dart';

class LaporanListScreen extends StatefulWidget {
  const LaporanListScreen({super.key});

  @override
  State<LaporanListScreen> createState() => _LaporanListScreenState();
}

class _LaporanListScreenState extends State<LaporanListScreen> {
  List _laporan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  Future<void> _loadLaporan() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getLaporan();
      setState(() => _laporan = data);
    } catch (e) {
      _showSnackbar('Gagal memuat data', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hapus(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Laporan'),
        content: const Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (konfirmasi == true) {
      await ApiService.deleteLaporan(id);
      _showSnackbar('Laporan berhasil dihapus');
      _loadLaporan();
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

  Color _statusColor(String status) {
    switch (status) {
      case 'selesai':
        return Colors.green;
      case 'proses':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Laporan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LaporanFormScreen()),
        ).then((_) => _loadLaporan()),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _laporan.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada laporan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LaporanFormScreen(),
                      ),
                    ).then((_) => _loadLaporan()),
                    child: const Text('Buat Laporan Pertama'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLaporan,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _laporan.length,
                itemBuilder: (_, i) {
                  final item = _laporan[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['judul'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusColor(
                                    item['status'] ?? '',
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item['status'] ?? '',
                                  style: TextStyle(
                                    color: _statusColor(item['status'] ?? ''),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['deskripsi'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 14,
                                color: Colors.blue[800],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['kategori'] ?? '',
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.orange,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LaporanFormScreen(laporan: item),
                                  ),
                                ).then((_) => _loadLaporan()),
                                tooltip: 'Edit',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _hapus(item['id']),
                                tooltip: 'Hapus',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
