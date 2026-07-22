// ============================================================
// FILE: lib/screens/signup_screen.dart
// PURPOSE: New student registration. Collects all required
//          data, then calls ApiService.signUp() to insert into MySQL.
// ============================================================

import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Controllers for each text field
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _universityController = TextEditingController(
    text: 'University of Frontier Technology, Bangladesh',
  );
  final _departmentController = TextEditingController(
    text: 'Software Engineering',
  );
  final _sessionController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Create a Student object from the form data
    final student = Student(
      name: _nameController.text.trim(),
      studentId: _studentIdController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      university: _universityController.text.trim(),
      department: _departmentController.text.trim(),
      session: _sessionController.text.trim(),
      cgpa: _cgpaController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    final result = await ApiService.signUp(student);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created! Please login.'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _sessionController.dispose();
    _cgpaController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword ? _obscurePassword : false,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1A73E8), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey, size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
          validator: validator ?? (v) => (v == null || v.isEmpty) ? '$label is required' : null,
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A73E8).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1A73E8)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Fill in your details to create your EduChain profile.',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ---- SECTION: Personal Info ----
              _sectionHeader('Personal Information', Icons.person_outline),
              const SizedBox(height: 12),

              _buildField(
                label: 'Full Name',
                controller: _nameController,
                hint: 'Md. Shafinur Rahman',
                icon: Icons.badge_outlined,
              ),
              _buildField(
                label: 'Student ID',
                controller: _studentIdController,
                hint: '2303023',
                icon: Icons.numbers,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Student ID is required';
                  if (v.length < 5) return 'Enter a valid student ID';
                  return null;
                },
              ),
              _buildField(
                label: 'Email Address',
                controller: _emailController,
                hint: 'your@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email is required';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              _buildField(
                label: 'Phone Number',
                controller: _phoneController,
                hint: '01XXXXXXXXX',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) => null, // Optional field
              ),
              _buildField(
                label: 'Password',
                controller: _passwordController,
                hint: 'Minimum 6 characters',
                icon: Icons.lock_outline,
                isPassword: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'At least 6 characters needed';
                  return null;
                },
              ),

              // ---- SECTION: Academic Info ----
              _sectionHeader('Academic Information', Icons.school_outlined),
              const SizedBox(height: 12),

              _buildField(
                label: 'University',
                controller: _universityController,
                hint: 'University name',
                icon: Icons.account_balance_outlined,
              ),
              _buildField(
                label: 'Department',
                controller: _departmentController,
                hint: 'Software Engineering',
                icon: Icons.computer_outlined,
              ),
              _buildField(
                label: 'Session (e.g., 2023-24)',
                controller: _sessionController,
                hint: '2023-24',
                icon: Icons.calendar_today_outlined,
              ),
              _buildField(
                label: 'Current CGPA (Optional)',
                controller: _cgpaController,
                hint: '3.75',
                icon: Icons.grade_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => null, // Optional
              ),

              const SizedBox(height: 8),

              // ---- SIGNUP BUTTON ----
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                    )
                  : ElevatedButton.icon(
                      onPressed: _signUp,
                      icon: const Icon(Icons.how_to_reg_rounded),
                      label: const Text('Create My Account'),
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A73E8), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A73E8),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Divider(color: Colors.grey.shade200)),
      ],
    );
  }
}
