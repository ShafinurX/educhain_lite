// ============================================================
// FILE: lib/screens/verify_screen.dart
// PURPOSE: Employer Verification Mode (V2.0)
//          - Scans Certificate QR -> Shows VALID/EXPIRED/REVOKED
//          - Scans Student Profile QR -> Shows verified profile
//          No login required.
// ============================================================

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  bool _isVerifying = false;
  Map<String, dynamic>? _verifyResult;
  bool _isProfileResult = false;

  final _hashController = TextEditingController();

  @override
  void dispose() {
    _hashController.dispose();
    super.dispose();
  }

  Future<void> _verifyByHash(String hash) async {
    setState(() {
      _isVerifying = true;
      _verifyResult = null;
      _isProfileResult = false;
    });

    final result = await ApiService.verifyCertificate(hash.trim());

    setState(() {
      _isVerifying = false;
      _verifyResult = result;
    });
  }

  Future<void> _verifyProfileById(String studentId) async {
    setState(() {
      _isVerifying = true;
      _verifyResult = null;
      _isProfileResult = true;
    });

    final result = await ApiService.getProfile(studentId.trim());

    setState(() {
      _isVerifying = false;
      _verifyResult = result;
    });
  }

  void _startQRScan() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannerPage(
          onScanCompleted: (rawData) {
            _hashController.text = rawData;

            if (rawData.contains('|')) {
              String hash = rawData.split('|')[1];
              _hashController.text = hash;
              _verifyByHash(hash);
            } else {
              _verifyProfileById(rawData);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Verify Certificate'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF34A853), Color(0xFF1E7E34)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.business_center_rounded,
                      color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Employer Verification Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'No login required. Enter hash or scan QR.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _StepCard(
              step: '1',
              text: 'Ask the student to show their Certificate or Profile QR',
              color: Color(0xFF1A73E8),
            ),
            const _StepCard(
              step: '2',
              text: 'Tap the camera button to scan the QR code',
              color: Color(0xFF34A853),
            ),
            const _StepCard(
              step: '3',
              text: 'Or paste the SHA-256 hash below and tap Verify',
              color: Color(0xFFEA4335),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _startQRScan,
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              label: const Text('Scan QR Code (Camera)',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("OR",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Enter Certificate Hash',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _hashController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: InputDecoration(
                hintText:
                'Paste the full 64-character SHA-256 hash here\ne.g., 2cf24dba5fb0a30e26e83b2ac5b9...',
                hintStyle: const TextStyle(fontSize: 11),
                prefixIcon: const Icon(Icons.fingerprint_rounded,
                    color: Color(0xFF1A73E8)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _isVerifying
                ? const Center(
              child:
              CircularProgressIndicator(color: Color(0xFF34A853)),
            )
                : ElevatedButton.icon(
              onPressed: () => _verifyByHash(_hashController.text),
              icon: const Icon(Icons.verified_user_rounded,
                  color: Colors.white),
              label: const Text('Verify Certificate',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34A853),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            // ---- VERIFICATION RESULT ----
            if (_verifyResult != null) ...[
              const SizedBox(height: 24),
              _isProfileResult
                  ? _ProfileVerificationResult(result: _verifyResult!)
                  : _VerificationResult(result: _verifyResult!),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SCANNER PAGE
// ============================================================
class ScannerPage extends StatefulWidget {
  final Function(String) onScanCompleted;
  const ScannerPage({super.key, required this.onScanCompleted});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: MobileScanner(
        onDetect: (capture) {
          if (_hasScanned) return;

          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() {
                _hasScanned = true;
              });
              widget.onScanCompleted(barcode.rawValue!);
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }
}

// ============================================================
// STEP CARD
// ============================================================
class _StepCard extends StatelessWidget {
  final String step;
  final String text;
  final Color color;

  const _StepCard(
      {required this.step, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              step,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style:
                TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CERTIFICATE VERIFICATION RESULT (V2.0 - with Expiry + Revocation)
// ============================================================
class _VerificationResult extends StatelessWidget {
  final Map<String, dynamic> result;

  const _VerificationResult({required this.result});

  @override
  Widget build(BuildContext context) {
    // Determine status: valid / expired / revoked / invalid
    final String status = result['status'] ?? 'invalid';

    Color color;
    IconData icon;
    String title;
    String subtitle;

    switch (status) {
      case 'valid':
        color = Colors.green;
        icon = Icons.check_circle_rounded;
        title = '✓ Certificate is VALID';
        subtitle =
        'This certificate is authentic and has not been modified.';
        break;
      case 'expired':
        color = Colors.orange;
        icon = Icons.access_time_rounded;
        title = '⏰ Certificate has EXPIRED';
        subtitle = result['message'] ??
            'This certificate has passed its expiry date.';
        break;
      case 'revoked':
        color = Colors.red;
        icon = Icons.cancel_rounded;
        title = '✗ Certificate is REVOKED';
        subtitle = result['message'] ??
            'This certificate has been revoked by the issuing institution.';
        break;
      default:
        color = Colors.red;
        icon = Icons.gpp_bad_rounded;
        title = '✗ Certificate is INVALID';
        subtitle =
        'This certificate could not be verified. It may be forged or modified.';
    }

    final data = result['data'] ?? result['certificate'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if ((status == 'valid' || status == 'expired' || status == 'revoked') && data != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _ResultRow('Student', data['student_name'] ?? data['name'] ?? '-'),
            _ResultRow('Certificate', data['title'] ?? '-'),
            _ResultRow('Issued By', data['issuing_org'] ?? '-'),
            _ResultRow('Issue Date', data['issue_date'] ?? '-'),
            if (data['expiry_date'] != null && data['expiry_date'] != '')
              _ResultRow('Expiry Date', data['expiry_date']),
            if (status == 'revoked')
              _ResultRow('Status', 'REVOKED'),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE VERIFICATION RESULT
// ============================================================
class _ProfileVerificationResult extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ProfileVerificationResult({required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isValid = result['status'] == 'success' ||
        result['success'] == true ||
        result['success'] == 'true';

    final color = isValid ? Colors.blue : Colors.red;
    final icon = isValid ? Icons.verified_user_rounded : Icons.gpp_bad_rounded;
    final title = isValid ? '✓ Student Profile Verified' : '✗ Profile Not Found';
    final subtitle = isValid
        ? 'This student profile has been verified on the secure digital network.'
        : 'This student ID could not be found in the system.';

    final student = result['student'] ?? result['data'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, size: 60, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          if (isValid && student != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            _ResultRow('Name', student['name'] ?? '-'),
            _ResultRow('Student ID', student['student_id'] ?? '-'),
            _ResultRow('University', student['university'] ?? '-'),
            _ResultRow('Department', student['department'] ?? '-'),
            _ResultRow('Session', student['session'] ?? '-'),
            _ResultRow('CGPA', student['cgpa'] ?? '-'),
            _ResultRow('Skills', student['skills'] ?? '-'),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// RESULT ROW HELPER
// ============================================================
class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}