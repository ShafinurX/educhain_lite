<?php
// ============================================================
// FILE: educhain_api/update_profile.php
// PURPOSE: Updates a student's profile information.
//
// FLUTTER CALL: POST http://10.0.2.2/educhain_api/update_profile.php
// BODY (JSON): { "student_id": "...", "cgpa": "...", "phone": "...", ... }
// ============================================================

require_once 'db_connect.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Only POST allowed']);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true);

if (empty($input['student_id'])) {
    echo json_encode(['success' => false, 'message' => 'student_id is required']);
    exit();
}

try {
    $stmt = $pdo->prepare('
        UPDATE students
        SET
            name = COALESCE(?, name),
            university = COALESCE(?, university),
            department = COALESCE(?, department),
            session = COALESCE(?, session),
            semester = COALESCE(?, semester),
            cgpa = COALESCE(?, cgpa),
            phone = COALESCE(?, phone),
            skills = COALESCE(?, skills)
        WHERE student_id = ?
    ');
    $stmt->execute([
        $input['name'] ?? null,
        $input['university'] ?? null,
        $input['department'] ?? null,
        $input['session'] ?? null,
        $input['semester'] ?? null,
        $input['cgpa'] ?? null,
        $input['phone'] ?? null,
        $input['skills'] ?? null,
        $input['student_id'],
    ]);

    if ($stmt->rowCount() > 0) {
        echo json_encode(['success' => true, 'message' => 'Profile updated successfully']);
    } else {
        echo json_encode(['success' => false, 'message' => 'No changes made or student not found']);
    }
} catch (PDOException $e) {
    echo json_encode(['success' => false, 'message' => 'Update failed: ' . $e->getMessage()]);
}
?>
