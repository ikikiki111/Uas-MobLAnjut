import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  // Ambil token dari storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Header dengan token
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // LOGIN
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // GET semua laporan
  static Future<List> getLaporan() async {
    final res = await http.get(
      Uri.parse(ApiConfig.laporan),
      headers: await _headers(),
    );
    final data = jsonDecode(res.body);
    return data['data'] ?? data; // sesuaikan dengan struktur response API-mu
  }

  // CREATE laporan
  static Future<Map<String, dynamic>> createLaporan(
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse(ApiConfig.laporan),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateLaporan(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse('${ApiConfig.laporan}/$id'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  // DELETE laporan
  static Future<void> deleteLaporan(int id) async {
    await http.delete(
      Uri.parse('${ApiConfig.laporan}/$id'),
      headers: await _headers(),
    );
  }

  static Future<void> logout() async {}
}
