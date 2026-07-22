// ============================================================
// FILE: lib/screens/profile_screen.dart
// PURPOSE: Shows student profile fetched from MySQL.
//          Displays personal info, academic details, and skills.
//          Includes Edit Profile functionality to update MySQL.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/student.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Student? _student;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('student_id') ?? '';

    final result = await ApiService.getProfile(studentId);

    if (result['success'] == true) {
      setState(() {
        _student = Student.fromJson(result['student']);
        _isLoading = false;
        _error = '';
      });
    } else {
      setState(() {
        _error = result['message'] ?? 'Failed to load profile';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          if (_student != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Profile',
              onPressed: () async {

                final bool? updated = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(student: _student!),
                  ),
                );


                if (updated == true) {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadProfile();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
          : _error.isNotEmpty
          ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A73E8), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(
                      _getInitials(_student?.name ?? '?'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _student?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${_student?.studentId ?? ''}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Verified badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'EduChain Verified Student',
                          style: TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---- INFO CARDS ----
            _InfoCard(
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _InfoRow(label: 'Email', value: _student?.email ?? '-'),
                _InfoRow(label: 'Phone', value: _student?.phone ?? '-'),
              ],
            ),

            const SizedBox(height: 12),

            _InfoCard(
              title: 'Academic Information',
              icon: Icons.school_outlined,
              children: [
                _InfoRow(label: 'University', value: _student?.university ?? '-'),
                _InfoRow(label: 'Department', value: _student?.department ?? '-'),
                _InfoRow(label: 'Session', value: _student?.session ?? '-'),
                _InfoRow(label: 'Semester', value: _student?.semester ?? '-'),
                _InfoRow(label: 'CGPA', value: _student?.cgpa ?? '-'),
              ],
            ),

            const SizedBox(height: 12),

            if (_student?.skills != null && _student!.skills!.isNotEmpty)
              _InfoCard(
                title: 'Skills',
                icon: Icons.star_outline,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _student!.skills!.split(',').map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A73E8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF1A73E8).withOpacity(0.3)),
                        ),
                        child: Text(
                          skill.trim(),
                          style: const TextStyle(
                            color: Color(0xFF1A73E8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

// ============================================================
// WIDGET: EditProfileScreen
// PURPOSE: Allows updating personal and academic student details.
// ============================================================
class EditProfileScreen extends StatefulWidget {
  final Student student;
  const EditProfileScreen({super.key, required this.student});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _universityController;
  late TextEditingController _departmentController;
  late TextEditingController _sessionController;
  late TextEditingController _semesterController;
  late TextEditingController _cgpaController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.student.name);
    _phoneController = TextEditingController(text: widget.student.phone ?? '');
    _universityController = TextEditingController(text: widget.student.university);
    _departmentController = TextEditingController(text: widget.student.department);
    _sessionController = TextEditingController(text: widget.student.session);
    _semesterController = TextEditingController(text: widget.student.semester ?? '');
    _cgpaController = TextEditingController(text: widget.student.cgpa ?? '');
    _skillsController = TextEditingController(text: widget.student.skills ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _sessionController.dispose();
    _semesterController.dispose();
    _cgpaController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);


    final updatedStudent = Student(
      id: widget.student.id,
      studentId: widget.student.studentId,
      email: widget.student.email,
      password: widget.student.password,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      university: _universityController.text.trim(),
      department: _departmentController.text.trim(),
      session: _sessionController.text.trim(),
      semester: _semesterController.text.trim(),
      cgpa: _cgpaController.text.trim(),
      skills: _skillsController.text.trim(),
    );

    final result = await ApiService.updateProfile(updatedStudent);

    setState(() => _isSaving = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to update profile'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.badge_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(labelText: 'University', prefixIcon: Icon(Icons.account_balance_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.computer_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _sessionController,
                decoration: const InputDecoration(labelText: 'Session', prefixIcon: Icon(Icons.calendar_today_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _semesterController,
                decoration: const InputDecoration(labelText: 'Semester', prefixIcon: Icon(Icons.calendar_month_outlined)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cgpaController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'CGPA', prefixIcon: Icon(Icons.grade_outlined)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(labelText: 'Skills (comma separated)', prefixIcon: Icon(Icons.star_outline)),
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
                  : ElevatedButton.icon(
                onPressed: _saveChanges,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: const Text('Save Changes', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1A73E8), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}