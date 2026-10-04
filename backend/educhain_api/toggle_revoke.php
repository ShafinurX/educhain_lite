<?php
// ============================================================
// FILE: educhain_api/toggle_revoke.php
// PURPOSE: Admin can revoke/unrevoke a certificate
// ============================================================

require_once 'db_connect.php';

$cert_id = $_POST['cert_id'] ?? '';
$action = $_POST['action'] ?? ''; // 'revoke' or 'unrevoke'

if (empty($cert_id) || empty($action)) {
    echo json_encode(['success' => false, 'message' => 'Missing parameters']);
    exit();
}

$new_status = ($action === 'revoke') ? 'revoked' : 'valid';

$stmt = $pdo->prepare('UPDATE certificates SET status = ? WHERE id = ?');
$result = $stmt->execute([$new_status, $cert_id]);

if ($result) {
    echo json_encode([
        'success' => true,
        'message' => "Certificate status updated to: $new_status"
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Update failed']);
}
?>
