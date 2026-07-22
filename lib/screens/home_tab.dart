// ============================================================
// FILE: lib/screens/home_tab.dart
// PURPOSE: The Home tab. Shows student name, summary stats
//          (total certificates, profile completion), and
//          quick-action buttons for key features.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart'; // QR Code ইম্পোর্ট করা হলো
import '../services/api_service.dart';
import '../models/certificate.dart';
import 'login_screen.dart';

class HomeTab extends StatefulWidget {
  final Function(int)? onTabChange;

  const HomeTab({super.key, this.onTabChange});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String _studentName = 'Student';
  String _studentId = '';
  String _department = '';
  List<Certificate> _recentCerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _studentName = prefs.getString('student_name') ?? 'Student';
    _studentId = prefs.getString('student_id') ?? '';


    if (_studentId.isNotEmpty) {
      final result = await ApiService.getProfile(_studentId);
      if (result['success'] == true) {
        setState(() {
          _department = result['student']['department'] ?? '';
        });
      }

      // Fetch recent certificates (last 3)
      final certs = await ApiService.getCertificates(_studentId);
      setState(() {
        _recentCerts = certs.take(3).toList();
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
    );
  }


  void _showProfileQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('My Profile QR', textAlign: TextAlign.center),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Scan to view my academic profile',
                style: TextStyle(color: Colors.grey, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              QrImageView(
                data: _studentId,
                version: QrVersions.auto,
                size: 200,
              ),
              const SizedBox(height: 12),
              Text(
                'Student ID: $_studentId',
                style: const TextStyle(fontWeight: FontWeight.bold),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
          : CustomScrollView(
        slivers: [
          // ---- CUSTOM APP BAR (gradient header) ----
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF1A73E8),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                tooltip: 'Sign Out',
                onPressed: _logout,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 90, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_studentName.split(' ').first}! ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _department.isNotEmpty
                          ? 'ID: $_studentId · $_department'
                          : 'ID: $_studentId',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---- STATS CARDS ----
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.description_rounded,
                          value: '${_recentCerts.length}',
                          label: 'Certificates',
                          color: const Color(0xFF1A73E8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          icon: Icons.verified_user_rounded,
                          value: '100%',
                          label: 'Verification',
                          color: Color(0xFF34A853),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _StatCard(
                          icon: Icons.security_rounded,
                          value: 'SHA-256',
                          label: 'Security',
                          color: Color(0xFFFBBC04),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---- QUICK ACTIONS ----
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _QuickActionCard(
                        icon: Icons.upload_file_rounded,
                        label: 'Upload Certificate',
                        color: const Color(0xFF1A73E8),
                        onTap: () {
                          widget.onTabChange?.call(2); // Certificates Tab (Index 2)-এ যাবে
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.qr_code_scanner_rounded,
                        label: 'Verify Certificate',
                        color: const Color(0xFF34A853),
                        onTap: () {
                          widget.onTabChange?.call(3); // Verify Tab (Index 3)-এ যাবে
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.manage_accounts_outlined,
                        label: 'Edit Profile',
                        color: const Color(0xFFEA4335),
                        onTap: () {
                          widget.onTabChange?.call(1); // Profile Tab (Index 1)-এ যাবে
                        },
                      ),
                      _QuickActionCard(
                        icon: Icons.share_rounded,
                        label: 'Share Profile QR',
                        color: const Color(0xFFFBBC04),
                        onTap: () {
                          _showProfileQRDialog(); // প্রোফাইল QR ডায়ালগ দেখাবে
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ---- RECENT CERTIFICATES ----
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Certificates',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          widget.onTabChange?.call(2); // Certificates Tab-এ যাবে
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  _recentCerts.isEmpty
                      ? const _EmptyState(
                    icon: Icons.description_outlined,
                    message: 'No certificates yet.\nUpload your first one!',
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentCerts.length,
                    itemBuilder: (_, i) {
                      final cert = _recentCerts[i];
                      return Card(
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A73E8).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: Color(0xFF1A73E8),
                            ),
                          ),
                          title: Text(
                            cert.title,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            cert.issuingOrg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---- HOW IT WORKS ----
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1A73E8).withOpacity(0.08),
                          const Color(0xFF0D47A1).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1A73E8).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: Color(0xFF1A73E8)),
                            SizedBox(width: 8),
                            Text(
                              'How EduChain Lite Works',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A73E8),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...[
                          ('1', 'Upload your certificate (PDF/Image)'),
                          ('2', 'SHA-256 hash is generated as tamper proof'),
                          ('3', 'QR code is created with your hash'),
                          ('4', 'Employer scans QR → instant verification'),
                        ].map((step) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A73E8),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  step.$1,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  step.$2,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- HELPER WIDGETS ----

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}