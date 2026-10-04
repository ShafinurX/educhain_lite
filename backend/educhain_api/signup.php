<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
// ============================================================
// FILE: educhain_api/signup.php
// PURPOSE: Registers a new student.
//          Receives JSON POST from Flutter, inserts into MySQL.
//
// SAVE LOCATION: C:\xampp\htdocs\educhain_api\signup.php
//
// FLUTTER CALL: POST http://10.0.2.2/educhain_api/signup.php
// BODY (JSON): { "name": "...", "student_id": "...", ... }
// ============================================================

require_once 'db_connect.php';

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST allowed']);
    exit();
}

// Read JSON body sent by Flutter
$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required = ['name', 'student_id', 'email', 'password', 'university', 'department', 'session'];
foreach ($required as $field) {
    if (empty($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Field '$field' is required"]);
        exit();
    }
}

// Check if email already exists
$stmt = $pdo->prepare('SELECT id FROM students WHERE email = ?');
$stmt->execute([$input['email']]);
if ($stmt->fetch()) {
    echo json_encode(['success' => false, 'message' => 'Email already registered']);
    exit();
}

// Check if student_id already exists
$stmt = $pdo->prepare('SELECT id FROM students WHERE student_id = ?');
$stmt->execute([$input['student_id']]);
if ($stmt->fetch()) {
    echo json_encode(['success' => false, 'message' => 'Student ID already registered']);
    exit();
}

// Hash the password with MD5 (for simplicity; use bcrypt in production)
$hashedPassword = md5($input['password']);

// Insert new student into database
try {
    $stmt = $pdo->prepare('
        INSERT INTO students (name, student_id, email, password, university, department, session, cgpa, phone, skills)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ');
    $stmt->execute([
        $input['name'],
        $input['student_id'],
        $input['email'],
        $hashedPassword,
        $input['university'],
        $input['department'],
        $input['session'],
        $input['cgpa'] ?? null,
        $input['phone'] ?? null,
        $input['skills'] ?? null,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Account created successfully! Please login.'
    ]);
} catch (PDOException $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Registration failed: ' . $e->getMessage()
    ]);
}
?>
