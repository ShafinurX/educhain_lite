<?php
// ============================================================
// FILE: educhain_api/login.php
// PURPOSE: Authenticates a student.
//          Checks email+password against MySQL, returns student data.
// ============================================================

// CORS Headers (For Flutter Web compatibility)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

require_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['email']) || empty($input['password'])) {
    echo json_encode(['success' => false, 'message' => 'Email and password are required']);
    exit();
}

// Hash the input password the same way we stored it
$hashedPassword = md5($input['password']);

// Look up student with matching email AND password
$stmt = $pdo->prepare('
    SELECT id, name, student_id, email, university, department, session, semester, cgpa, phone, skills
    FROM students
    WHERE email = ? AND password = ?
');
$stmt->execute([$input['email'], $hashedPassword]);
$student = $stmt->fetch();

if ($student) {
    // Login successful
    echo json_encode([
        'success' => true,
        'message' => 'Login successful',
        'student' => $student  // Send student data back to Flutter
    ]);
} else {
    // Wrong email or password
    echo json_encode([
        'success' => false,
        'message' => 'Incorrect email or password'
    ]);
}
?>
