<?php
// ============================================================
// FILE: educhain_api/add_certificate.php
// PURPOSE: Saves certificate metadata + SHA-256 hash to MySQL.
//
// SAVE LOCATION: C:\xampp\htdocs\educhain_api\add_certificate.php
//
// FLUTTER CALL: POST http://10.0.2.2/educhain_api/add_certificate.php
// BODY (JSON): { "student_id":"...", "title":"...", "sha256_hash":"...", ... }
// ============================================================

require_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

// Validate required fields
$required = ['student_id', 'title', 'issuing_org', 'issue_date', 'file_url', 'sha256_hash'];
foreach ($required as $field) {
    if (empty($input[$field])) {
        echo json_encode(['success' => false, 'message' => "Field '$field' is required"]);
        exit();
    }
}

// Prevent duplicate certificate (same hash = same file already uploaded)
$stmt = $pdo->prepare('SELECT id FROM certificates WHERE sha256_hash = ?');
$stmt->execute([$input['sha256_hash']]);
if ($stmt->fetch()) {
    echo json_encode(['success' => false, 'message' => 'This certificate has already been uploaded']);
    exit();
}

// Build QR data: studentId|sha256Hash (this is what the QR code encodes)
$qrData = $input['student_id'] . '|' . $input['sha256_hash'];

try {
    $stmt = $pdo->prepare('
        INSERT INTO certificates (student_id, title, issuing_org, issue_date, expiry_date, file_url, sha256_hash, qr_data)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ');
    $stmt->execute([
        $input['student_id'],
        $input['title'],
        $input['issuing_org'],
        $input['issue_date'],
        $input['expiry_date'] ?? null,
        $input['file_url'],
        $input['sha256_hash'],
        $qrData,
    ]);

    echo json_encode([
        'success' => true,
        'message' => 'Certificate saved successfully',
        'certificate_id' => $pdo->lastInsertId(),
        'qr_data' => $qrData,
    ]);
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Failed to save: ' . $e->getMessage()]);
}
?>
