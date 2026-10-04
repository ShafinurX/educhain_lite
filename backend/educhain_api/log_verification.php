<?php
// ============================================================
// FILE: educhain_api/log_verification.php
// PURPOSE: Log a verification event
// ============================================================

require_once 'db_connect.php';

$cert_id = $_POST['cert_id'] ?? '';
$student_id = $_POST['student_id'] ?? '';

if (empty($cert_id) || empty($student_id)) {
    echo json_encode(['success' => false, 'message' => 'Missing parameters']);
    exit();
}

$ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';

$stmt = $pdo->prepare('
    INSERT INTO verification_logs (certificate_id, student_id, verifier_ip, verified_at)
    VALUES (?, ?, ?, NOW())
');
$result = $stmt->execute([$cert_id, $student_id, $ip]);

echo json_encode(['success' => $result]);
?>
