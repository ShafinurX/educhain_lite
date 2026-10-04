<?php
// ============================================================
// FILE: educhain_api/db_connect.php
// PURPOSE: Database connection configuration.
//          Every other PHP file will include this.
//
// SAVE LOCATION: C:\xampp\htdocs\educhain_api\db_connect.php
// ============================================================

$host = 'localhost';
$dbname = 'educhain_db';
$username = 'root';   // Default XAMPP MySQL username
$password = '';        // Default XAMPP MySQL password (empty)

// Create PDO connection
// PDO is safer than mysqli - it prevents SQL injection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    // If connection fails, return JSON error
    header('Content-Type: application/json');
    echo json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $e->getMessage()
    ]);
    die();
}

// Set response headers so Flutter can read the JSON
// CORS allows requests from any origin (needed for emulator)
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle browser preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
