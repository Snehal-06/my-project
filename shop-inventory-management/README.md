# Shop & Inventory Management System

A beginner-friendly college mini project built with Core PHP, MySQL, HTML5, CSS3 and vanilla JavaScript. It is designed to run locally with XAMPP and phpMyAdmin.

## Features

- Database-backed administrator login/logout, PHP sessions, password verification, CSRF tokens and protected admin pages.
- Dashboard statistics for products, categories, suppliers, total stock, low stock and revenue, plus recent sales.
- Product CRUD, unique SKU, search, category/stock filters, pagination and product detail/history.
- Category CRUD with duplicate prevention and safe deletion rules.
- Supplier CRUD, supplier search, contact details and linked products.
- Inventory list, low/out-of-stock highlighting, safe stock adjustment and movement history.
- Cash sales with multiple products, server-side price calculations, row locking, database transactions, stock decrement and printable invoice.
- Reports for daily/monthly sales, total revenue, best-selling products, low stock and out-of-stock items.
- Responsive blue-and-white dashboard UI.

## Technology / requirements

- Windows 10/11 (or another OS with XAMPP)
- XAMPP with Apache, PHP 8.1+ recommended, MySQL/MariaDB
- phpMyAdmin (included in standard XAMPP)
- Browser: Chrome, Edge, Firefox or Safari
- MySQL storage engine InnoDB; MySQL 5.7+ or modern MariaDB recommended

No PHP framework, Node.js, React, paid API, or payment gateway is used. Google Fonts is an optional cosmetic enhancement; the app remains functional if it cannot load.

## Install on Windows with XAMPP

1. Install XAMPP from the official Apache Friends site and open **XAMPP Control Panel**.
2. Click **Start** next to **Apache** and **MySQL**.
3. Extract `shop-inventory-management.zip`.
4. Copy the included `shop-inventory-management` folder to `C:\xampp\htdocs\`. The expected file is `C:\xampp\htdocs\shop-inventory-management\index.php`.
5. Open `http://localhost/phpmyadmin/` in your browser.
6. Choose **Import**, select the project's `database.sql`, and click **Import/Go**. The script creates `shop_inventory_db` and sample data.
7. Open `config/database.php`. The default XAMPP settings are host `127.0.0.1`, database `shop_inventory_db`, username `root`, and blank password. If your MySQL root account has a password, update `$pass` accordingly.
8. Visit **http://localhost/shop-inventory-management/**.
9. Sign in using the demo credentials below and change the demo password before using real data.

### Demo login

- Username: `admin`
- Password: `Admin@12345`

The SQL file includes a bcrypt password hash for this demo account. If the account does not authenticate on a customized PHP environment, use the secure setup procedure below to replace the hash.

### Secure admin password setup / reset

The included demo account is for a local classroom demonstration only. For a non-demo deployment, generate a hash with PHP and store it in the `users.password_hash` column. For example, create a temporary PHP file inside the project folder named `make_hash.php` containing:

```php
<?php echo password_hash('YourStrongPasswordHere', PASSWORD_DEFAULT), PHP_EOL;
```

Open `http://localhost/shop-inventory-management/make_hash.php`, copy the hash, then in phpMyAdmin run:

```sql
UPDATE users SET password_hash = 'PASTE_GENERATED_HASH_HERE' WHERE username = 'admin';
```

Delete `make_hash.php` immediately after use. Do not store or share plaintext passwords in a production environment. Do not expose phpMyAdmin or this local app directly to the public internet.

## Main modules

- **Dashboard**: live counts, stock overview, revenue and latest sales.
- **Products**: create, read, edit, filter, search and safely delete catalogue entries.
- **Categories**: maintain product groups. A category with linked products cannot be deleted.
- **Suppliers**: contact records, search, detail view and linked product list. A supplier with linked products cannot be deleted.
- **Inventory**: stock levels, low/out-of-stock status, adjustments and movement history.
- **Sales**: create cash sale, view transaction details and print an invoice. Prices and totals are recalculated from the database, not trusted from the browser.
- **Reports**: current day/month revenue, recent daily sales, best sellers and stock exception reports.

## Suggested demonstration flow

1. Log in and show dashboard figures.
2. Add a category and a supplier.
3. Add a product with a unique SKU and opening stock.
4. Search/filter products and edit a product.
5. Adjust stock and show the movement log.
6. Create a sale for one or more products; show that stock decreases.
7. Try selling more than available stock; the transaction should be rejected without partial updates.
8. Open and print the invoice; review Reports.
9. Try deleting a category/supplier with linked products and a product with sales history to demonstrate safe constraints.

## Common issues

- **Database connection failed**: make sure MySQL is running, import `database.sql`, and check host/database/username/password in `config/database.php`.
- **404 / page not found**: confirm the project folder is exactly `C:\xampp\htdocs\shop-inventory-management\` and the URL includes `/shop-inventory-management/`.
- **Login rejected**: check the `admin` row in `users`, ensure the hash is present, and use the demo credentials exactly as listed. Use the password reset steps above if needed.
- **Apache or MySQL won't start**: another application may be using ports 80/443 or 3306. Check the XAMPP logs and resolve the port conflict.
- **Headers already sent**: do not add spaces or a UTF-8 BOM before `<?php` in PHP files.
- **No category available**: create a category before adding a product.
- **Cannot delete a category/supplier/product**: this is intentional when linked records exist; reassign/unlink where appropriate or keep historical records.
- **Invoice print opens a blank popup**: allow the browser to open the invoice page normally from the Sales module; the invoice also has its own Print button.

## Security and implementation notes

- PDO prepared statements are used for user input queries.
- Output is escaped with `htmlspecialchars()` in HTML views.
- POST forms that modify data require CSRF tokens; delete actions require POST and confirmation.
- Passwords are verified with `password_verify()`; the seeded account uses a password hash.
- Sales use InnoDB transactions and `SELECT ... FOR UPDATE` row locks to validate/decrement stock atomically.
- Stock cannot be adjusted below zero through the app. Product quantity is also constrained by a database check on supported MySQL/MariaDB versions.
- Historical sale items reference products with `ON DELETE RESTRICT`; products with sale history are not deletable in the UI.
- This is an educational local application. Before any production use, add role management, rate limiting, backups, deployment hardening, HTTPS, and formal audit/logging policies.

## Testing status

The package was checked for PHP syntax using `php -l` on the generated PHP files. A live browser/database integration test was not available during packaging, so login, SQL import, sales concurrency and print behavior should still be confirmed on your own XAMPP installation using the demonstration flow above. Do not treat the sample data as real shop records.
