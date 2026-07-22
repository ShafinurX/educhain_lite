

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student.dart';
import '../models/certificate.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.0.200/educhain_api';



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
}
