import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class HashService {
  static String computeSHA256(Uint8List fileBytes) {
    final digest = sha256.convert(fileBytes);
    return digest.toString();
  }

  static String computeStringHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool verifyHash(String originalHash, String computedHash) {
    return originalHash == computedHash;
  }
}
