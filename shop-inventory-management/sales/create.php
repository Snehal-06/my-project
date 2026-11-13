<?php
require_once __DIR__.'/../includes/auth.php';
$pageTitle='New sale'; $base='/shop-inventory-management';
$products=$pdo->query('SELECT id,name,sku,selling_price,quantity FROM products WHERE quantity>0 ORDER BY name')->fetchAll();
$error='';
if($_SERVER['REQUEST_METHOD']==='POST') {
 csrf_check(); $ids=$_POST['product_id']??[]; $qtys=$_POST['quantity']??[];
 if(!is_array($ids)||!is_array($qtys)||count($ids)===0||count($ids)!==count($qtys)) $error='Add at least one valid sale item.';
 else {
  $items=[];
  foreach($ids as $i=>$pid) { if(!valid_int($pid,1)||!valid_int($qtys[$i]??null,1)) {$error='Select a product and enter a positive whole-number quantity.';break;} $pid=(int)$pid;$qty=(int)$qtys[$i];$items[$pid]=($items[$pid]??0)+$qty; }
  if(!$error) {
   $pdo->beginTransaction();
   try {
    $lines=[];$total=0.0;
    foreach($items as $pid=>$qty) { $st=$pdo->prepare('SELECT id,name,sku,selling_price,quantity FROM products WHERE id=? FOR UPDATE');$st->execute([$pid]);$p=$st->fetch();if(!$p)throw new RuntimeException('A selected product no longer exists.');if((int)$p['quantity']<$qty)throw new RuntimeException('Insufficient stock for '.$p['name'].'. Available: '.$p['quantity'].'.');$price=(float)$p['selling_price'];$line=round($price*$qty,2);$total=round($total+$line,2);$lines[]=['product'=>$p,'qty'=>$qty,'price'=>$price,'line'=>$line]; }
    $invoice='INV-'.date('Ymd').'-'.strtoupper(bin2hex(random_bytes(3)));
    $st=$pdo->prepare("INSERT INTO sales(invoice_no,user_id,subtotal,grand_total,status) VALUES(?,?,?,?, 'completed')");$st->execute([$invoice,$_SESSION['user_id'],$total,$total]);$saleId=(int)$pdo->lastInsertId();
    $ins=$pdo->prepare('INSERT INTO sale_items(sale_id,product_id,quantity,unit_price,line_total) VALUES(?,?,?,?,?)');$upd=$pdo->prepare('UPDATE products SET quantity=quantity-? WHERE id=? AND quantity>=?');
    foreach($lines as $line) {$p=$line['product'];$ins->execute([$saleId,$p['id'],$line['qty'],$line['price'],$line['line']]);$upd->execute([$line['qty'],$p['id'],$line['qty']]);if($upd->rowCount()!==1)throw new RuntimeException('Stock changed during sale. Please retry.');audit_stock($pdo,(int)$p['id'],-$line['qty'],'Sale '.$invoice,$_SESSION['user_id']);}
    $pdo->commit();flash('success','Sale completed. Invoice '.$invoice.' created.');redirect('view.php?id='.$saleId);
   } catch(Throwable $e) { if($pdo->inTransaction())$pdo->rollBack();$error=$e instanceof RuntimeException?$e->getMessage():'Sale could not be completed. No changes were saved.'; }
  }
 }
}
require __DIR__.'/../includes/header.php';require __DIR__.'/../includes/sidebar.php';
?>
<div class="page-heading"><div><h1>New cash sale</h1><p>Select products and quantities. Prices and totals are calculated securely on the server.</p></div><a class="btn" href="index.php">← Sales history</a></div>
<div class="panel form-panel wide-form"><?php if($error):?><div class="alert error"><?=e($error)?></div><?php endif;?><?php if(!$products):?><div class="alert warning">No products are currently in stock. Add products or receive stock before creating a sale.</div><?php endif;?>
<form method="post" id="sale-form"><input type="hidden" name="csrf_token" value="<?=e(csrf_token())?>"><div id="sale-items"><div class="sale-line"><label>Product<select name="product_id[]" required><option value="">Select product</option><?php foreach($products as $p):?><option value="<?=$p['id']?>" data-price="<?=e($p['selling_price'])?>" data-stock="<?=$p['quantity']?>"><?=e($p['name'].' ('.$p['sku'].') — stock '.$p['quantity'].' — '.money($p['selling_price']))?></option><?php endforeach;?></select></label><label>Quantity<input name="quantity[]" type="number" min="1" step="1" required value="1"></label><button type="button" class="btn danger remove-line" aria-label="Remove item">×</button></div></div>
<button type="button" class="btn" id="add-sale-line">＋ Add another item</button><div class="sale-note"><strong>Sale total</strong><span id="sale-total-preview">Calculated on submit</span><small>Preview is indicative only. Final total uses database prices.</small></div><div class="form-actions"><button class="btn primary" <?= $products ? '' : 'disabled' ?>>Confirm cash sale</button><a class="btn" href="index.php">Cancel</a></div></form></div>
<script>window.saleProductOptions = <?=json_encode(array_map(fn($p)=>['id'=>(int)$p['id'],'label'=>$p['name'].' ('.$p['sku'].') — stock '.$p['quantity'].' — '.money($p['selling_price']),'price'=>(float)$p['selling_price'],'stock'=>(int)$p['quantity']],$products),JSON_HEX_TAG|JSON_HEX_APOS|JSON_HEX_AMP|JSON_HEX_QUOT)?>;</script>
<?php require __DIR__.'/../includes/footer.php'; ?>
