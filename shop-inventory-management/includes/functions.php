<?php
function e($v): string { return htmlspecialchars((string)$v, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8'); }
function redirect(string $url): never { header('Location: '.$url); exit; }
function csrf_token(): string { if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token'] = bin2hex(random_bytes(32)); return $_SESSION['csrf_token']; }
function csrf_check(): void { if ($_SERVER['REQUEST_METHOD'] === 'POST') { $sent=$_POST['csrf_token']??''; if (!is_string($sent) || !hash_equals($_SESSION['csrf_token']??'', $sent)) { http_response_code(419); exit('Invalid or expired form token. Go back and try again.'); } } }
function flash(string $type, string $message): void { $_SESSION['flash']=['type'=>$type,'message'=>$message]; }
function get_flash(): ?array { $f=$_SESSION['flash']??null; unset($_SESSION['flash']); return $f; }
function money($n): string { return '₹'.number_format((float)$n,2); }
function require_post(): void { if ($_SERVER['REQUEST_METHOD'] !== 'POST') { http_response_code(405); exit('Method not allowed.'); } }
function valid_int($v, int $min=0): bool { return filter_var($v, FILTER_VALIDATE_INT)!==false && (int)$v >= $min; }
function valid_price($v): bool { return is_numeric($v) && is_finite((float)$v) && (float)$v >= 0 && round((float)$v,2)==(float)$v; }
function audit_stock(PDO $pdo,int $productId,int $change,string $reason,int $userId): void { $s=$pdo->prepare('INSERT INTO stock_movements(product_id,quantity_change,reason,user_id) VALUES(?,?,?,?)'); $s->execute([$productId,$change,$reason,$userId]); }
