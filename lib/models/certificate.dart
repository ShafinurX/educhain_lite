// ============================================================
// FILE: lib/models/certificate.dart
// PURPOSE: Blueprint for a Certificate object.
//          Matches the 'certificates' table in MySQL.
// ============================================================

class Certificate {
  final int? id;
  final String studentId;       // Foreign key → students.student_id
  final String title;           // e.g., "BSc in Software Engineering"
  final String issuingOrg;      // e.g., "University of Frontier Technology"
  final String issueDate;       // e.g., "2026-02-14"
  final String? expiryDate;     // Optional expiry
  final String fileUrl;         // URL to the certificate file on server
  final String sha256Hash;      // SHA-256 hash of the file (tamper detection)
  final String? qrData;         // Data encoded in QR code
  final String uploadedAt;      // Timestamp

  Certificate({
    this.id,
    required this.studentId,
    required this.title,
    required this.issuingOrg,
    required this.issueDate,
    this.expiryDate,
    required this.fileUrl,
    required this.sha256Hash,
    this.qrData,
    required this.uploadedAt,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: int.tryParse(json['id'].toString()),
      studentId: json['student_id'] ?? '',
      title: json['title'] ?? '',
      issuingOrg: json['issuing_org'] ?? '',
      issueDate: json['issue_date'] ?? '',
      expiryDate: json['expiry_date'],
      fileUrl: json['file_url'] ?? '',
      sha256Hash: json['sha256_hash'] ?? '',
      qrData: json['qr_data'],
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'title': title,
      'issuing_org': issuingOrg,
      'issue_date': issueDate,
      'expiry_date': expiryDate,
      'file_url': fileUrl,
      'sha256_hash': sha256Hash,
      'qr_data': qrData,
    };
  }
}
