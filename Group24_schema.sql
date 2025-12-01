-- Group 24: Krish Lenka, Matsvei Liapich, Sonia Kanchi
-- BuyMe Online Auction System - Electronics Category
-- CS 336 Fall 2025

DROP DATABASE IF EXISTS cs336project;
CREATE DATABASE cs336project;
USE cs336project;

-- =====================================================
-- STAFF TABLES (Admin and Customer Representatives)
-- =====================================================

CREATE TABLE Staff (
    emp_id VARCHAR(15) PRIMARY KEY NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Admin (
    emp_id VARCHAR(15) PRIMARY KEY NOT NULL,
    FOREIGN KEY (emp_id) REFERENCES Staff(emp_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE CustomerRep (
    emp_id VARCHAR(15) PRIMARY KEY NOT NULL,
    created_by VARCHAR(15),
    FOREIGN KEY (emp_id) REFERENCES Staff(emp_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (created_by) REFERENCES Admin(emp_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- USER TABLES (Buyers and Sellers)
-- =====================================================

CREATE TABLE User (
    user_id VARCHAR(15) PRIMARY KEY NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE Buyer (
    buyer_id VARCHAR(15) PRIMARY KEY NOT NULL,
    shipping_address TEXT NOT NULL,
    default_card VARCHAR(20) NOT NULL,
    FOREIGN KEY (buyer_id) REFERENCES User(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Seller (
    seller_id VARCHAR(15) PRIMARY KEY NOT NULL,
    earnings DECIMAL(12,2) DEFAULT 0.00,
    rating DECIMAL(3,2) DEFAULT 0.00,
    total_ratings INT DEFAULT 0,
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- CATEGORY HIERARCHY (Electronics with 3+ subcategories)
-- =====================================================

CREATE TABLE Category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    category_description TEXT,
    parent_id INT DEFAULT NULL,
    FOREIGN KEY (parent_id) REFERENCES Category(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Insert Electronics category hierarchy
INSERT INTO Category (category_name, category_description, parent_id) VALUES
-- Root category
('Electronics', 'Electronic devices and accessories', NULL),

-- Level 1 subcategories
('Computers', 'Desktop and portable computing devices', 1),
('Phones', 'Mobile phones and accessories', 1),
('Audio', 'Audio equipment and accessories', 1),
('Gaming', 'Gaming consoles and accessories', 1),

-- Level 2 subcategories - Computers
('Laptops', 'Portable computers', 2),
('Desktops', 'Desktop computers and workstations', 2),
('Tablets', 'Tablet computers', 2),

-- Level 2 subcategories - Phones
('Smartphones', 'Mobile smartphones', 3),
('Phone Accessories', 'Cases, chargers, and other phone accessories', 3),

-- Level 2 subcategories - Audio
('Headphones', 'Over-ear and on-ear headphones', 4),
('Earbuds', 'In-ear wireless and wired earbuds', 4),
('Speakers', 'Portable and home speakers', 4),

-- Level 2 subcategories - Gaming
('Consoles', 'Gaming consoles (PlayStation, Xbox, Nintendo)', 5),
('Controllers', 'Gaming controllers and accessories', 5),

-- Level 3 subcategories - Laptops
('Gaming Laptops', 'High-performance gaming laptops', 6),
('Business Laptops', 'Professional and business laptops', 6),
('Ultrabooks', 'Thin and lightweight laptops', 6);

-- =====================================================
-- ITEM TABLE with category-specific fields
-- =====================================================

CREATE TABLE Item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_title VARCHAR(200) NOT NULL,
    item_description TEXT NOT NULL,
    item_condition ENUM('New', 'Like New', 'Very Good', 'Good', 'Acceptable') NOT NULL,
    image_url TEXT,
    category_id INT NOT NULL,
    -- Electronics-specific fields
    brand VARCHAR(100),
    model VARCHAR(100),
    year_manufactured INT,
    warranty_months INT DEFAULT 0,
    -- Computer-specific fields
    processor VARCHAR(100),
    ram_gb INT,
    storage_gb INT,
    screen_size_inches DECIMAL(4,1),
    -- Phone-specific fields
    carrier VARCHAR(50),
    storage_capacity VARCHAR(20),
    color VARCHAR(50),
    -- Audio-specific fields
    connectivity ENUM('Wired', 'Wireless', 'Both'),
    driver_size VARCHAR(20),
    battery_life_hours INT,
    -- Gaming-specific fields
    platform VARCHAR(50),
    region VARCHAR(20),
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =====================================================
-- AUCTION TABLE
-- =====================================================

CREATE TABLE Auction (
    auction_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    seller_id VARCHAR(15) NOT NULL,
    start_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    close_date DATETIME NOT NULL,
    initial_price DECIMAL(12,2) NOT NULL,
    increment_price DECIMAL(12,2) NOT NULL,
    min_price DECIMAL(12,2) NOT NULL,  -- Secret minimum price
    current_high_bid DECIMAL(12,2) DEFAULT 0.00,
    high_bidder_id VARCHAR(15) DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_closed BOOLEAN DEFAULT FALSE,
    winner_id VARCHAR(15) DEFAULT NULL,
    final_price DECIMAL(12,2) DEFAULT NULL,
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (high_bidder_id) REFERENCES Buyer(buyer_id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (winner_id) REFERENCES Buyer(buyer_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- BID TABLE with automatic bidding support
-- =====================================================

CREATE TABLE Bid (
    bid_id INT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    buyer_id VARCHAR(15) NOT NULL,
    bid_amount DECIMAL(12,2) NOT NULL,
    bid_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_auto_bid BOOLEAN DEFAULT FALSE,
    max_auto_bid DECIMAL(12,2) DEFAULT NULL,  -- For automatic bidding
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- AUTO BID SETTINGS (for automatic bidding feature)
-- =====================================================

CREATE TABLE AutoBidSetting (
    auto_bid_id INT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    buyer_id VARCHAR(15) NOT NULL,
    max_bid_amount DECIMAL(12,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_auction_buyer (auction_id, buyer_id),
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- =====================================================
-- ALERT TABLE (for item notifications)
-- =====================================================

CREATE TABLE Alert (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    buyer_id VARCHAR(15) NOT NULL,
    category_id INT,
    keyword VARCHAR(200),
    min_price DECIMAL(12,2),
    max_price DECIMAL(12,2),
    brand VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- NOTIFICATION TABLE (stores triggered alerts)
-- =====================================================

CREATE TABLE Notification (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(15) NOT NULL,
    message TEXT NOT NULL,
    auction_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- QUESTION/TICKET TABLE (for customer support)
-- =====================================================

CREATE TABLE Question (
    question_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(15) NOT NULL,
    subject VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    response TEXT,
    responded_by VARCHAR(15),
    is_resolved BOOLEAN DEFAULT FALSE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    resolved_at DATETIME,
    FOREIGN KEY (user_id) REFERENCES User(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (responded_by) REFERENCES CustomerRep(emp_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- =====================================================
-- SALES TABLE (for completed transactions)
-- =====================================================

CREATE TABLE Sale (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    auction_id INT NOT NULL,
    item_id INT NOT NULL,
    buyer_id VARCHAR(15) NOT NULL,
    seller_id VARCHAR(15) NOT NULL,
    final_price DECIMAL(12,2) NOT NULL,
    shipping_address TEXT NOT NULL,
    payment_card VARCHAR(20) NOT NULL,
    sale_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (auction_id) REFERENCES Auction(auction_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (item_id) REFERENCES Item(item_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES Buyer(buyer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Seller(seller_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- =====================================================
-- INITIAL DATA: Admin account (required before system start)
-- =====================================================

INSERT INTO Staff (emp_id, password, email, phone, first_name, last_name, dob)
VALUES ('admin', 'admin123', 'admin@buyme.com', '555-0001', 'System', 'Administrator', '1990-01-01');

INSERT INTO Admin (emp_id) VALUES ('admin');

-- Insert a test customer representative
INSERT INTO Staff (emp_id, password, email, phone, first_name, last_name, dob)
VALUES ('rep1', 'rep123', 'rep1@buyme.com', '555-0002', 'John', 'Smith', '1992-05-15');

INSERT INTO CustomerRep (emp_id, created_by) VALUES ('rep1', 'admin');

-- Insert test users
INSERT INTO User (user_id, password, email, phone, first_name, last_name, dob)
VALUES 
('buyer1', 'pass123', 'buyer1@email.com', '555-1001', 'Alice', 'Johnson', '1995-03-20'),
('seller1', 'pass123', 'seller1@email.com', '555-1002', 'Bob', 'Williams', '1988-07-12'),
('user1', 'pass123', 'user1@email.com', '555-1003', 'Carol', 'Davis', '1990-11-08');

INSERT INTO Buyer (buyer_id, shipping_address, default_card)
VALUES 
('buyer1', '123 Main St, New Brunswick, NJ 08901', '4111111111111111'),
('user1', '456 Oak Ave, Princeton, NJ 08540', '4222222222222222');

INSERT INTO Seller (seller_id, earnings, rating, total_ratings)
VALUES 
('seller1', 0.00, 4.5, 10),
('user1', 0.00, 4.8, 5);

-- Insert sample items and auctions
INSERT INTO Item (item_title, item_description, item_condition, category_id, brand, model, year_manufactured, 
    processor, ram_gb, storage_gb, screen_size_inches)
VALUES 
('MacBook Pro 14" M3', 'Apple MacBook Pro with M3 chip, excellent condition', 'Like New', 6, 'Apple', 'MacBook Pro 14', 2023, 'Apple M3', 16, 512, 14.2),
('Dell XPS 15', 'Dell XPS 15 with Intel i7, perfect for professionals', 'Very Good', 17, 'Dell', 'XPS 15 9530', 2023, 'Intel Core i7-13700H', 32, 1000, 15.6),
('Gaming Laptop ASUS ROG', 'High-performance gaming laptop with RTX 4070', 'New', 16, 'ASUS', 'ROG Strix G16', 2024, 'Intel Core i9-13980HX', 32, 1000, 16.0);

INSERT INTO Item (item_title, item_description, item_condition, category_id, brand, model, year_manufactured,
    carrier, storage_capacity, color)
VALUES 
('iPhone 15 Pro Max', 'Apple iPhone 15 Pro Max 256GB, Natural Titanium', 'New', 9, 'Apple', 'iPhone 15 Pro Max', 2023, 'Unlocked', '256GB', 'Natural Titanium'),
('Samsung Galaxy S24 Ultra', 'Samsung flagship with S Pen, Titanium Black', 'Like New', 9, 'Samsung', 'Galaxy S24 Ultra', 2024, 'Unlocked', '512GB', 'Titanium Black');

INSERT INTO Item (item_title, item_description, item_condition, category_id, brand, model, year_manufactured,
    connectivity, battery_life_hours)
VALUES 
('Sony WH-1000XM5', 'Industry-leading noise cancelling headphones', 'New', 11, 'Sony', 'WH-1000XM5', 2023, 'Wireless', 30),
('AirPods Pro 2nd Gen', 'Apple AirPods Pro with USB-C charging case', 'Like New', 12, 'Apple', 'AirPods Pro 2', 2023, 'Wireless', 6);

INSERT INTO Item (item_title, item_description, item_condition, category_id, brand, model, year_manufactured,
    platform, region)
VALUES 
('PlayStation 5', 'Sony PS5 Disc Edition with 2 controllers', 'Very Good', 14, 'Sony', 'PlayStation 5', 2022, 'PlayStation', 'USA'),
('Nintendo Switch OLED', 'Nintendo Switch OLED Model White', 'New', 14, 'Nintendo', 'Switch OLED', 2023, 'Nintendo', 'USA');

-- Create sample auctions
INSERT INTO Auction (item_id, seller_id, close_date, initial_price, increment_price, min_price, current_high_bid)
VALUES 
(1, 'seller1', DATE_ADD(NOW(), INTERVAL 7 DAY), 1500.00, 50.00, 1800.00, 1550.00),
(2, 'seller1', DATE_ADD(NOW(), INTERVAL 5 DAY), 1000.00, 25.00, 1200.00, 1025.00),
(3, 'user1', DATE_ADD(NOW(), INTERVAL 10 DAY), 1800.00, 50.00, 2000.00, 0.00),
(4, 'seller1', DATE_ADD(NOW(), INTERVAL 3 DAY), 900.00, 25.00, 1000.00, 950.00),
(5, 'user1', DATE_ADD(NOW(), INTERVAL 6 DAY), 800.00, 20.00, 900.00, 0.00),
(6, 'seller1', DATE_ADD(NOW(), INTERVAL 4 DAY), 250.00, 10.00, 300.00, 280.00),
(7, 'user1', DATE_ADD(NOW(), INTERVAL 8 DAY), 180.00, 5.00, 200.00, 0.00),
(8, 'seller1', DATE_ADD(NOW(), INTERVAL 2 DAY), 400.00, 15.00, 450.00, 430.00),
(9, 'user1', DATE_ADD(NOW(), INTERVAL 9 DAY), 300.00, 10.00, 350.00, 0.00);

-- Sample bids
INSERT INTO Bid (auction_id, buyer_id, bid_amount)
VALUES 
(1, 'buyer1', 1550.00),
(2, 'buyer1', 1025.00),
(4, 'buyer1', 950.00),
(6, 'buyer1', 280.00),
(8, 'buyer1', 430.00);

-- Update high bidders
UPDATE Auction SET high_bidder_id = 'buyer1' WHERE auction_id IN (1, 2, 4, 6, 8);

-- Sample alert
INSERT INTO Alert (buyer_id, category_id, keyword, max_price, brand)
VALUES ('buyer1', 6, 'MacBook', 2000.00, 'Apple');
