-- Shop & Inventory Management System
-- Import this file in phpMyAdmin. MySQL 5.7+/MariaDB 10.4+ recommended.
CREATE DATABASE IF NOT EXISTS shop_inventory_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE shop_inventory_db;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS stock_movements; DROP TABLE IF EXISTS sale_items; DROP TABLE IF EXISTS sales; DROP TABLE IF EXISTS products; DROP TABLE IF EXISTS suppliers; DROP TABLE IF EXISTS categories; DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;
CREATE TABLE users (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, username VARCHAR(80) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL, full_name VARCHAR(150) NOT NULL,
 is_active TINYINT(1) NOT NULL DEFAULT 1, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE categories (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL UNIQUE,
 description TEXT NULL, created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;
CREATE TABLE suppliers (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(150) NOT NULL,
 phone VARCHAR(30) NULL, email VARCHAR(190) NULL, address TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_supplier_name(name)
) ENGINE=InnoDB;
CREATE TABLE products (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(180) NOT NULL,
 sku VARCHAR(80) NOT NULL UNIQUE, category_id INT UNSIGNED NOT NULL,
 supplier_id INT UNSIGNED NULL, purchase_price DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 selling_price DECIMAL(12,2) NOT NULL DEFAULT 0.00, quantity INT NOT NULL DEFAULT 0,
 minimum_stock INT UNSIGNED NOT NULL DEFAULT 5, description TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 INDEX idx_product_name(name), INDEX idx_product_category(category_id), INDEX idx_product_supplier(supplier_id), INDEX idx_product_stock(quantity),
 CONSTRAINT fk_product_category FOREIGN KEY(category_id) REFERENCES categories(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_product_supplier FOREIGN KEY(supplier_id) REFERENCES suppliers(id) ON UPDATE CASCADE ON DELETE SET NULL,
 CONSTRAINT chk_product_prices CHECK(purchase_price>=0 AND selling_price>=0), CONSTRAINT chk_product_quantity CHECK(quantity>=0)
) ENGINE=InnoDB;
CREATE TABLE sales (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, invoice_no VARCHAR(40) NOT NULL UNIQUE,
 user_id INT UNSIGNED NULL, subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
 grand_total DECIMAL(12,2) NOT NULL DEFAULT 0.00, status ENUM('completed','cancelled') NOT NULL DEFAULT 'completed',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_sales_created(created_at), INDEX idx_sales_user(user_id),
 CONSTRAINT fk_sale_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;
CREATE TABLE sale_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, sale_id BIGINT UNSIGNED NOT NULL,
 product_id INT UNSIGNED NOT NULL, quantity INT UNSIGNED NOT NULL,
 unit_price DECIMAL(12,2) NOT NULL, line_total DECIMAL(12,2) NOT NULL,
 INDEX idx_sale_items_sale(sale_id), INDEX idx_sale_items_product(product_id),
 CONSTRAINT fk_saleitem_sale FOREIGN KEY(sale_id) REFERENCES sales(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT fk_saleitem_product FOREIGN KEY(product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE RESTRICT,
 CONSTRAINT chk_saleitem_quantity CHECK(quantity>0), CONSTRAINT chk_saleitem_price CHECK(unit_price>=0 AND line_total>=0)
) ENGINE=InnoDB;
CREATE TABLE stock_movements (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, product_id INT UNSIGNED NOT NULL,
 quantity_change INT NOT NULL, reason VARCHAR(255) NOT NULL, user_id INT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_stock_product_date(product_id,created_at), INDEX idx_stock_user(user_id),
 CONSTRAINT fk_stock_product FOREIGN KEY(product_id) REFERENCES products(id) ON UPDATE CASCADE ON DELETE CASCADE,
 CONSTRAINT fk_stock_user FOREIGN KEY(user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;
-- Initial administrator: username admin / password Admin@12345
-- This bcrypt hash was generated with PHP password_hash('Admin@12345', PASSWORD_DEFAULT).
INSERT INTO users(username,password_hash,full_name,is_active) VALUES('admin','$2y$12$FQg656.mCWvhljFJBQwUVOb2aiG/ja1TtPSzKCrfH8L4bLI9wwrru','Shop Administrator',1);
-- Sample master data to make the first dashboard useful. Safe to delete from the UI.
INSERT INTO categories(name,description) VALUES ('Groceries','Daily household groceries'),('Beverages','Packaged drinks and beverages'),('Household','Cleaning and household items');
INSERT INTO suppliers(name,phone,email,address) VALUES ('Demo Wholesale Supplier','9876543210','supplier@example.com','Main Market, Local Area');
INSERT INTO products(name,sku,category_id,supplier_id,purchase_price,selling_price,quantity,minimum_stock,description) VALUES
('Rice 1 kg','RICE-001',1,1,48.00,60.00,35,10,'Demo packaged rice'),
('Tea 250 g','TEA-001',1,1,72.00,90.00,8,10,'Demo tea pack'),
('Mineral Water 1 L','WATER-001',2,1,12.00,20.00,0,12,'Demo bottled water'),
('Dishwash Bar','HOME-001',3,1,18.00,25.00,22,5,'Demo household cleaning item');
INSERT INTO stock_movements(product_id,quantity_change,reason,user_id) VALUES (1,35,'Demo initial stock',1),(2,8,'Demo initial stock',1),(3,0,'Demo starting balance',1),(4,22,'Demo initial stock',1);
