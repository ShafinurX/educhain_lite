<?php
// ============================================================
// FILE: educhain_api/get_verification_history.php
// PURPOSE: Get verification history for a student
// ============================================================

require_once 'db_connect.php';

$student_id = $_GET['student_id'] ?? '';

if (empty($student_id)) {
    echo json_encode(['success' => false, 'message' => 'Student ID required']);
    exit();
}

$stmt = $pdo->prepare('
    SELECT
        vl.log_id,
        vl.certificate_id,
        vl.verifier_ip,
        vl.verified_at,
        c.title AS certificate_title
    FROM verification_logs vl
    LEFT JOIN certificates c ON vl.certificate_id = c.id
    WHERE vl.student_id = ?
    ORDER BY vl.verified_at DESC
');
$stmt->execute([$student_id]);
$logs = $stmt->fetchAll();

echo json_encode([
    'success' => true,
    'history' => $logs
]);
?>
