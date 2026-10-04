<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");

// ============================================================
// FILE: educhain_api/get_profile.php
// PURPOSE: Returns full student profile by student_id.
//
// FLUTTER CALL: GET http://10.0.2.2/educhain_api/get_profile.php?student_id=2303023
// ============================================================

require_once 'db_connect.php';

$studentId = $_GET['student_id'] ?? '';

if (empty($studentId)) {
    echo json_encode(['success' => false, 'message' => 'student_id is required']);
    exit();
}

$stmt = $pdo->prepare('SELECT * FROM students WHERE student_id = ?');
$stmt->execute([$studentId]);
$student = $stmt->fetch();

if ($student) {
    unset($student['password']); // Never send password back!
    echo json_encode(['success' => true, 'student' => $student]);
} else {
    echo json_encode(['success' => false, 'message' => 'Student not found']);
}
?>
