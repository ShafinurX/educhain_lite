// ============================================================
// FILE: lib/models/student.dart
// PURPOSE: This is a "blueprint" (Model) for a Student.
//          It defines what data a student object holds.
//          Think of it like a table row from MySQL, but in Dart.
// ============================================================

class Student {
  final int? id;              // MySQL auto-increment ID
  final String name;          // Full name
  final String studentId;     // University student ID (e.g., 2303023)
  final String email;         // Email address
  final String password;      // Hashed password (never store plain text)
  final String university;    // University name
  final String department;    // Department (e.g., Software Engineering)
  final String session;       // Academic session (e.g., 2023-24)
  final String? semester;     // Current semester
  final String? cgpa;         // Current CGPA
  final String? phone;        // Phone number
  final String? skills;       // Comma-separated skills
  final String? profilePicUrl; // URL to profile picture in server

  Student({
    this.id,
    required this.name,
    required this.studentId,
    required this.email,
    required this.password,
    required this.university,
    required this.department,
    required this.session,
    this.semester,
    this.cgpa,
    this.phone,
    this.skills,
    this.profilePicUrl,
  });

  // fromJson: Converts a JSON map (from PHP API) into a Student object
  // Example JSON: {"id": 1, "name": "Shafinur", "student_id": "2303023", ...}
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: int.tryParse(json['id'].toString()),
      name: json['name'] ?? '',
      studentId: json['student_id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      university: json['university'] ?? '',
      department: json['department'] ?? '',
      session: json['session'] ?? '',
      semester: json['semester'],
      cgpa: json['cgpa'],
      phone: json['phone'],
      skills: json['skills'],
      profilePicUrl: json['profile_pic_url'],
    );
  }

  // toJson: Converts a Student object into a JSON map (to send to PHP API)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'student_id': studentId,
      'email': email,
      'password': password,
      'university': university,
      'department': department,
      'session': session,
      'semester': semester,
      'cgpa': cgpa,
      'phone': phone,
      'skills': skills,
      'profile_pic_url': profilePicUrl,
    };
  }
}
