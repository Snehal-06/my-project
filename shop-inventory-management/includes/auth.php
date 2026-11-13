<?php
require_once __DIR__.'/../config/database.php'; require_once __DIR__.'/functions.php';
if (empty($_SESSION['user_id'])) { flash('error','Please log in to continue.'); redirect('/shop-inventory-management/login.php'); }
