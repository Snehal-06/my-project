<?php
// Update these values to match your local XAMPP/MySQL configuration.
$host = '127.0.0.1'; $db = 'shop_inventory_db'; $user = 'root'; $pass = '';
$options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC, PDO::ATTR_EMULATE_PREPARES => false];
try { $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass, $options); }
catch (PDOException $e) { http_response_code(500); exit('Database connection failed. Check config/database.php and import database.sql.'); }
if (session_status() !== PHP_SESSION_ACTIVE) { ini_set('session.use_strict_mode', '1'); session_set_cookie_params(['httponly'=>true,'samesite'=>'Lax','secure'=>!empty($_SERVER['HTTPS'])]); session_start(); }
