import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/certificate.dart';

class ApiService {
  // ⚠️ CHANGE THIS to your PC's IPv4 Address
  static const String _baseUrl = 'http://192.168.0.199/educhain_api';

  // ----------------------------------------------------------
  // SIGN UP
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> signUp(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(student.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // LOGIN
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // GET PROFILE
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> getProfile(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_profile.php?student_id=$studentId'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // UPDATE PROFILE
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> updateProfile(Student student) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/update_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(student.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // ADD CERTIFICATE
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> addCertificate(Certificate cert) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/add_certificate.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(cert.toJson()),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // GET CERTIFICATES
  // ----------------------------------------------------------
  static Future<List<Certificate>> getCertificates(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_certificates.php?student_id=$studentId'),
      );
      final data = jsonDecode(response.body);
      if (data['success']) {
        return (data['certificates'] as List)
            .map((c) => Certificate.fromJson(c))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ----------------------------------------------------------
  // VERIFY CERTIFICATE (V2.0 - with expiry + revocation)
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> verifyCertificate(String hash) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/verify_certificate.php?hash=$hash'),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // TOGGLE REVOKE (Admin only) — NEW
  // ----------------------------------------------------------
  static Future<Map<String, dynamic>> toggleRevoke(int certId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/toggle_revoke.php'),
        body: {'cert_id': certId.toString(), 'action': action},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ----------------------------------------------------------
  // GET VERIFICATION HISTORY — NEW
  // ----------------------------------------------------------
  static Future<List<dynamic>> getVerificationHistory(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get_verification_history.php?student_id=$studentId'),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data['history'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}