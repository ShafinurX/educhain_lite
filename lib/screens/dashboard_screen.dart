// ============================================================
// FILE: lib/screens/dashboard_screen.dart
// PURPOSE: The main hub after login. Shows a bottom navigation
//          bar with: Home, Profile, Certificates, Verify.
//          Each tab is a separate screen/widget.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_tab.dart';
import 'profile_screen.dart';
import 'certificates_screen.dart';
import 'verify_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Which bottom nav tab is active

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    // Show confirmation dialog before logging out
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Clear saved login data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ডার্ট কম্পাইলার এরর এড়াতে স্ক্রিন লিস্টটি সরাসরি build মেথডের ভেতরে ডিক্লেয়ার করা হলো
    final List<Widget> _screens = [
      HomeTab(
        onTabChange: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),                         // Tab 0: Home overview
      const ProfileScreen(),     // Tab 1: Student profile
      const CertificatesScreen(), // Tab 2: Certificate management
      const VerifyScreen(),      // Tab 3: Employer verification
    ];

    return Scaffold(
      body: _screens[_selectedIndex], // Show active tab
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: const Color(0xFF1A73E8).withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1A73E8)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF1A73E8)),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description_rounded, color: Color(0xFF1A73E8)),
            label: 'Certificates',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF1A73E8)),
            label: 'Verify',
          ),
        ],
      ),
    );
  }
}