<?php
// ============================================================
// FILE: educhain_api/verify_certificate.php
// PURPOSE: Core verification endpoint (V2.0)
//          - Checks hash
//          - Checks expiry date
//          - Checks revocation status
//          - Logs verification event
// ============================================================

require_once 'db_connect.php';

$hash = $_GET['hash'] ?? '';

if (empty($hash)) {
    echo json_encode(['success' => false, 'message' => 'Hash parameter is required']);
    exit();
}

// Validate hash format
if (!preg_match('/^[a-f0-9]{64}$/', strtolower($hash))) {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid hash format',
        'verified' => false,
    ]);
    exit();
}

// Look up the hash with status and expiry check
$stmt = $pdo->prepare('
    SELECT
        c.id,
        c.title,
        c.issuing_org,
        c.issue_date,
        c.expiry_date,
        c.sha256_hash,
        c.uploaded_at,
        c.status,
        s.name AS student_name,
        s.student_id,
        s.university,
        s.department
    FROM certificates c
    JOIN students s ON c.student_id = s.student_id
    WHERE c.sha256_hash = ?
');
$stmt->execute([$hash]);
$certificate = $stmt->fetch();

if ($certificate) {
    // Check revocation status
    if ($certificate['status'] === 'revoked') {
        echo json_encode([
            'success' => false,
            'verified' => false,
            'status' => 'revoked',
            'message' => 'This certificate has been REVOKED by the issuing institution.',
            'certificate' => $certificate,
        ]);
        exit();
    }
    
    // Check expiry date
    if (!empty($certificate['expiry_date'])) {
        $today = date('Y-m-d');
        if ($certificate['expiry_date'] < $today) {
            echo json_encode([
                'success' => false,
                'verified' => false,
                'status' => 'expired',
                'message' => 'This certificate has EXPIRED on ' . $certificate['expiry_date'],
                'certificate' => $certificate,
            ]);
            exit();
        }
    }
    
    // Log verification event
    logVerification($pdo, $certificate['id'], $certificate['student_id']);
    
    // Valid certificate
    echo json_encode([
        'success' => true,
        'verified' => true,
        'status' => 'valid',
        'message' => 'Certificate is VALID and authentic.',
        'certificate' => $certificate,
    ]);
} else {
    echo json_encode([
        'success' => false,
        'verified' => false,
        'status' => 'invalid',
        'message' => 'Certificate NOT FOUND or has been TAMPERED.',
    ]);
}

// Log verification function
function logVerification($pdo, $cert_id, $student_id) {
    try {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $stmt = $pdo->prepare('
            INSERT INTO verification_logs (certificate_id, student_id, verifier_ip, verified_at)
            VALUES (?, ?, ?, NOW())
        ');
        $stmt->execute([$cert_id, $student_id, $ip]);
    } catch (Exception $e) {
        // Silent fail for logging
    }
}
?>
