<?php
// ============================================================
// FILE: educhain_api/get_certificates.php
// PURPOSE: Returns all certificates for a student.
//
// FLUTTER CALL: GET http://10.0.2.2/educhain_api/get_certificates.php?student_id=2303023
// ============================================================

require_once 'db_connect.php';

$studentId = $_GET['student_id'] ?? '';

if (empty($studentId)) {
    echo json_encode(['success' => false, 'message' => 'student_id is required']);
    exit();
}

$stmt = $pdo->prepare('
    SELECT * FROM certificates
    WHERE student_id = ?
    ORDER BY uploaded_at DESC
');
$stmt->execute([$studentId]);
$certificates = $stmt->fetchAll();

echo json_encode([
    'success' => true,
    'count' => count($certificates),
    'certificates' => $certificates,
]);
?>
