// ============================================================
// FILE: lib/screens/certificates_screen.dart
// PURPOSE: The Certificate Management module.
//          - Lists all uploaded certificates from MySQL
//          - Has an "Add Certificate" button that opens a form
//          - Generates SHA-256 hash for each uploaded file
//          - Shows a QR code for each certificate
// ============================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/certificate.dart';
import '../services/api_service.dart';
import '../services/hash_service.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<Certificate> _certificates = [];
  bool _isLoading = true;
  String _studentId = '';

  @override
  void initState() {
    super.initState();
    _loadCertificates();
  }

  Future<void> _loadCertificates() async {
    final prefs = await SharedPreferences.getInstance();
    _studentId = prefs.getString('student_id') ?? '';
    final certs = await ApiService.getCertificates(_studentId);
    setState(() {
      _certificates = certs;
      _isLoading = false;
    });
  }


  void _showAddCertificateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCertificateSheet(
        studentId: _studentId,
        onAdded: () {
          Navigator.pop(context);
          _loadCertificates(); // Refresh list after adding
        },
      ),
    );
  }


  void _showQRCode(Certificate cert) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(cert.title, style: const TextStyle(fontSize: 16)),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan to verify this certificate',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              QrImageView(
                // QR encodes: studentId|sha256hash for verification
                data: '${cert.studentId}|${cert.sha256Hash}',
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hash: ${cert.sha256Hash.substring(0, 16)}...',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Certificates'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCertificateSheet,
        backgroundColor: const Color(0xFF1A73E8),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Certificate', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
          : _certificates.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No certificates yet',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button below to upload your first certificate',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _certificates.length,
        itemBuilder: (_, i) {
          final cert = _certificates[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Certificate header
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF1A73E8),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cert.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              cert.issuingOrg,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Valid badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: Colors.green),
                            SizedBox(width: 4),
                            Text(
                              'Valid',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Issue date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Issued: ${cert.issueDate}',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Hash preview
                  Row(
                    children: [
                      const Icon(Icons.fingerprint_rounded,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Hash: ${cert.sha256Hash.substring(0, 20)}...',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Action button (পূর্ণাঙ্গ উইডথ সহ চমৎকার View QR বাটন)
                  OutlinedButton.icon(
                    onPressed: () => _showQRCode(cert),
                    icon: const Icon(Icons.qr_code_rounded, size: 16),
                    label: const Text('View QR Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1A73E8),
                      side: const BorderSide(color: Color(0xFF1A73E8)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size(double.infinity, 44), // ফুল উইডথ ফিক্স
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---- ADD CERTIFICATE BOTTOM SHEET ----
class AddCertificateSheet extends StatefulWidget {
  final String studentId;
  final VoidCallback onAdded;

  const AddCertificateSheet({
    super.key,
    required this.studentId,
    required this.onAdded,
  });

  @override
  State<AddCertificateSheet> createState() => _AddCertificateSheetState();
}

class _AddCertificateSheetState extends State<AddCertificateSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _orgController = TextEditingController();
  final _dateController = TextEditingController();

  String? _selectedFileName;
  Uint8List? _selectedFileBytes;
  String? _computedHash;
  bool _isLoading = false;

  // Lets user pick a PDF or image file
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // Load file bytes into memory
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final hash = HashService.computeSHA256(bytes); // Compute SHA-256

      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = bytes;
        _computedHash = hash;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_computedHash == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a certificate file')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // NOTE: In production, you'd upload the actual file to the server.
    // For now, we save the metadata + hash to MySQL.
    final cert = Certificate(
      studentId: widget.studentId,
      title: _titleController.text.trim(),
      issuingOrg: _orgController.text.trim(),
      issueDate: _dateController.text.trim(),
      fileUrl: 'uploads/${widget.studentId}/$_selectedFileName',
      sha256Hash: _computedHash!,
      uploadedAt: DateTime.now().toIso8601String(),
    );

    final result = await ApiService.addCertificate(cert);
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      widget.onAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to save certificate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Add Certificate',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ---- CERTIFICATE TITLE ----
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Certificate Title',
                  hintText: 'e.g., BSc in Software Engineering',
                  prefixIcon: Icon(Icons.title, color: Color(0xFF1A73E8)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // ---- ISSUING ORG ----
              TextFormField(
                controller: _orgController,
                decoration: const InputDecoration(
                  labelText: 'Issuing Organization',
                  hintText: 'University / Company name',
                  prefixIcon: Icon(Icons.business_outlined, color: Color(0xFF1A73E8)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              // ---- ISSUE DATE ----
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Issue Date (YYYY-MM-DD)',
                  hintText: '2026-02-14',
                  prefixIcon: Icon(Icons.calendar_month_outlined, color: Color(0xFF1A73E8)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),

              // ---- FILE PICKER ----
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _computedHash != null
                        ? Colors.green.shade50
                        : const Color(0xFF1A73E8).withOpacity(0.05),
                    border: Border.all(
                      color: _computedHash != null
                          ? Colors.green
                          : const Color(0xFF1A73E8).withOpacity(0.3),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _computedHash != null
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        size: 36,
                        color: _computedHash != null
                            ? Colors.green
                            : const Color(0xFF1A73E8),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFileName ?? 'Tap to select certificate file',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _computedHash != null
                              ? Colors.green
                              : const Color(0xFF1A73E8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_computedHash != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'SHA-256: ${_computedHash!.substring(0, 24)}...',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Supported: PDF, JPG, PNG',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),


              _isLoading
                  ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
              )
                  : ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save Certificate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}