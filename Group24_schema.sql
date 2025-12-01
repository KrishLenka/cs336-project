-- MySQL dump 10.13  Distrib 9.5.0, for macos15 (arm64)
--
-- Host: localhost    Database: cs336project
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'da4533e6-ce87-11f0-b228-d1998cf219a2:1-70';

--
-- Table structure for table `Admin`
--

DROP TABLE IF EXISTS `Admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Admin` (
  `emp_id` varchar(15) NOT NULL,
  PRIMARY KEY (`emp_id`),
  CONSTRAINT `admin_ibfk_1` FOREIGN KEY (`emp_id`) REFERENCES `Staff` (`emp_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Admin`
--

LOCK TABLES `Admin` WRITE;
/*!40000 ALTER TABLE `Admin` DISABLE KEYS */;
INSERT INTO `Admin` VALUES ('admin');
/*!40000 ALTER TABLE `Admin` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Alert`
--

DROP TABLE IF EXISTS `Alert`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Alert` (
  `alert_id` int NOT NULL AUTO_INCREMENT,
  `buyer_id` varchar(15) NOT NULL,
  `category_id` int DEFAULT NULL,
  `keyword` varchar(200) DEFAULT NULL,
  `min_price` decimal(12,2) DEFAULT NULL,
  `max_price` decimal(12,2) DEFAULT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`alert_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `alert_ibfk_1` FOREIGN KEY (`buyer_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `alert_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `Category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Alert`
--

LOCK TABLES `Alert` WRITE;
/*!40000 ALTER TABLE `Alert` DISABLE KEYS */;
INSERT INTO `Alert` VALUES (1,'buyer1',6,'MacBook',NULL,2000.00,'Apple',1,'2025-12-01 02:41:07');
/*!40000 ALTER TABLE `Alert` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Auction`
--

DROP TABLE IF EXISTS `Auction`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Auction` (
  `auction_id` int NOT NULL AUTO_INCREMENT,
  `item_id` int NOT NULL,
  `seller_id` varchar(15) NOT NULL,
  `start_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `close_date` datetime NOT NULL,
  `initial_price` decimal(12,2) NOT NULL,
  `increment_price` decimal(12,2) NOT NULL,
  `min_price` decimal(12,2) NOT NULL,
  `current_high_bid` decimal(12,2) DEFAULT '0.00',
  `high_bidder_id` varchar(15) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `is_closed` tinyint(1) DEFAULT '0',
  `winner_id` varchar(15) DEFAULT NULL,
  `final_price` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`auction_id`),
  KEY `item_id` (`item_id`),
  KEY `seller_id` (`seller_id`),
  KEY `high_bidder_id` (`high_bidder_id`),
  KEY `winner_id` (`winner_id`),
  CONSTRAINT `auction_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `Item` (`item_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `auction_ibfk_2` FOREIGN KEY (`seller_id`) REFERENCES `Seller` (`seller_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `auction_ibfk_3` FOREIGN KEY (`high_bidder_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `auction_ibfk_4` FOREIGN KEY (`winner_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Auction`
--

LOCK TABLES `Auction` WRITE;
/*!40000 ALTER TABLE `Auction` DISABLE KEYS */;
INSERT INTO `Auction` VALUES (1,1,'seller1','2025-12-01 02:41:07','2025-12-08 02:41:07',1500.00,50.00,1800.00,1550.00,'buyer1',1,0,NULL,NULL),(2,2,'seller1','2025-12-01 02:41:07','2025-12-06 02:41:07',1000.00,25.00,1200.00,1025.00,'buyer1',1,0,NULL,NULL),(3,3,'user1','2025-12-01 02:41:07','2025-12-11 02:41:07',1800.00,50.00,2000.00,0.00,NULL,1,0,NULL,NULL),(4,4,'seller1','2025-12-01 02:41:07','2025-12-04 02:41:07',900.00,25.00,1000.00,950.00,'buyer1',1,0,NULL,NULL),(5,5,'user1','2025-12-01 02:41:07','2025-12-07 02:41:07',800.00,20.00,900.00,0.00,NULL,1,0,NULL,NULL),(6,6,'seller1','2025-12-01 02:41:07','2025-12-05 02:41:07',250.00,10.00,300.00,280.00,'buyer1',1,0,NULL,NULL),(7,7,'user1','2025-12-01 02:41:07','2025-12-09 02:41:07',180.00,5.00,200.00,0.00,NULL,1,0,NULL,NULL),(8,8,'seller1','2025-12-01 02:41:07','2025-12-03 02:41:07',400.00,15.00,450.00,430.00,'buyer1',1,0,NULL,NULL),(9,9,'user1','2025-12-01 02:41:07','2025-12-10 02:41:07',300.00,10.00,350.00,0.00,NULL,1,0,NULL,NULL);
/*!40000 ALTER TABLE `Auction` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `AutoBidSetting`
--

DROP TABLE IF EXISTS `AutoBidSetting`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `AutoBidSetting` (
  `auto_bid_id` int NOT NULL AUTO_INCREMENT,
  `auction_id` int NOT NULL,
  `buyer_id` varchar(15) NOT NULL,
  `max_bid_amount` decimal(12,2) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`auto_bid_id`),
  UNIQUE KEY `unique_auction_buyer` (`auction_id`,`buyer_id`),
  KEY `buyer_id` (`buyer_id`),
  CONSTRAINT `autobidsetting_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `Auction` (`auction_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `autobidsetting_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `AutoBidSetting`
--

LOCK TABLES `AutoBidSetting` WRITE;
/*!40000 ALTER TABLE `AutoBidSetting` DISABLE KEYS */;
/*!40000 ALTER TABLE `AutoBidSetting` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Bid`
--

DROP TABLE IF EXISTS `Bid`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Bid` (
  `bid_id` int NOT NULL AUTO_INCREMENT,
  `auction_id` int NOT NULL,
  `buyer_id` varchar(15) NOT NULL,
  `bid_amount` decimal(12,2) NOT NULL,
  `bid_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_auto_bid` tinyint(1) DEFAULT '0',
  `max_auto_bid` decimal(12,2) DEFAULT NULL,
  PRIMARY KEY (`bid_id`),
  KEY `auction_id` (`auction_id`),
  KEY `buyer_id` (`buyer_id`),
  CONSTRAINT `bid_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `Auction` (`auction_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `bid_ibfk_2` FOREIGN KEY (`buyer_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Bid`
--

LOCK TABLES `Bid` WRITE;
/*!40000 ALTER TABLE `Bid` DISABLE KEYS */;
INSERT INTO `Bid` VALUES (1,1,'buyer1',1550.00,'2025-12-01 02:41:07',0,NULL),(2,2,'buyer1',1025.00,'2025-12-01 02:41:07',0,NULL),(3,4,'buyer1',950.00,'2025-12-01 02:41:07',0,NULL),(4,6,'buyer1',280.00,'2025-12-01 02:41:07',0,NULL),(5,8,'buyer1',430.00,'2025-12-01 02:41:07',0,NULL);
/*!40000 ALTER TABLE `Bid` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Buyer`
--

DROP TABLE IF EXISTS `Buyer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Buyer` (
  `buyer_id` varchar(15) NOT NULL,
  `shipping_address` text NOT NULL,
  `default_card` varchar(20) NOT NULL,
  PRIMARY KEY (`buyer_id`),
  CONSTRAINT `buyer_ibfk_1` FOREIGN KEY (`buyer_id`) REFERENCES `User` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Buyer`
--

LOCK TABLES `Buyer` WRITE;
/*!40000 ALTER TABLE `Buyer` DISABLE KEYS */;
INSERT INTO `Buyer` VALUES ('buyer1','123 Main St, New Brunswick, NJ 08901','4111111111111111'),('user1','456 Oak Ave, Princeton, NJ 08540','4222222222222222');
/*!40000 ALTER TABLE `Buyer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Category`
--

DROP TABLE IF EXISTS `Category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Category` (
  `category_id` int NOT NULL AUTO_INCREMENT,
  `category_name` varchar(100) NOT NULL,
  `category_description` text,
  `parent_id` int DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  KEY `parent_id` (`parent_id`),
  CONSTRAINT `category_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `Category` (`category_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Category`
--

LOCK TABLES `Category` WRITE;
/*!40000 ALTER TABLE `Category` DISABLE KEYS */;
INSERT INTO `Category` VALUES (1,'Electronics','Electronic devices and accessories',NULL),(2,'Computers','Desktop and portable computing devices',1),(3,'Phones','Mobile phones and accessories',1),(4,'Audio','Audio equipment and accessories',1),(5,'Gaming','Gaming consoles and accessories',1),(6,'Laptops','Portable computers',2),(7,'Desktops','Desktop computers and workstations',2),(8,'Tablets','Tablet computers',2),(9,'Smartphones','Mobile smartphones',3),(10,'Phone Accessories','Cases, chargers, and other phone accessories',3),(11,'Headphones','Over-ear and on-ear headphones',4),(12,'Earbuds','In-ear wireless and wired earbuds',4),(13,'Speakers','Portable and home speakers',4),(14,'Consoles','Gaming consoles (PlayStation, Xbox, Nintendo)',5),(15,'Controllers','Gaming controllers and accessories',5),(16,'Gaming Laptops','High-performance gaming laptops',6),(17,'Business Laptops','Professional and business laptops',6),(18,'Ultrabooks','Thin and lightweight laptops',6);
/*!40000 ALTER TABLE `Category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `CustomerRep`
--

DROP TABLE IF EXISTS `CustomerRep`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `CustomerRep` (
  `emp_id` varchar(15) NOT NULL,
  `created_by` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`emp_id`),
  KEY `created_by` (`created_by`),
  CONSTRAINT `customerrep_ibfk_1` FOREIGN KEY (`emp_id`) REFERENCES `Staff` (`emp_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `customerrep_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `Admin` (`emp_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `CustomerRep`
--

LOCK TABLES `CustomerRep` WRITE;
/*!40000 ALTER TABLE `CustomerRep` DISABLE KEYS */;
INSERT INTO `CustomerRep` VALUES ('rep1','admin');
/*!40000 ALTER TABLE `CustomerRep` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Item`
--

DROP TABLE IF EXISTS `Item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Item` (
  `item_id` int NOT NULL AUTO_INCREMENT,
  `item_title` varchar(200) NOT NULL,
  `item_description` text NOT NULL,
  `item_condition` enum('New','Like New','Very Good','Good','Acceptable') NOT NULL,
  `image_url` text,
  `category_id` int NOT NULL,
  `brand` varchar(100) DEFAULT NULL,
  `model` varchar(100) DEFAULT NULL,
  `year_manufactured` int DEFAULT NULL,
  `warranty_months` int DEFAULT '0',
  `processor` varchar(100) DEFAULT NULL,
  `ram_gb` int DEFAULT NULL,
  `storage_gb` int DEFAULT NULL,
  `screen_size_inches` decimal(4,1) DEFAULT NULL,
  `carrier` varchar(50) DEFAULT NULL,
  `storage_capacity` varchar(20) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `connectivity` enum('Wired','Wireless','Both') DEFAULT NULL,
  `driver_size` varchar(20) DEFAULT NULL,
  `battery_life_hours` int DEFAULT NULL,
  `platform` varchar(50) DEFAULT NULL,
  `region` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `item_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `Category` (`category_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Item`
--

LOCK TABLES `Item` WRITE;
/*!40000 ALTER TABLE `Item` DISABLE KEYS */;
INSERT INTO `Item` VALUES (1,'MacBook Pro 14\" M3','Apple MacBook Pro with M3 chip, excellent condition','Like New',NULL,6,'Apple','MacBook Pro 14',2023,0,'Apple M3',16,512,14.2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(2,'Dell XPS 15','Dell XPS 15 with Intel i7, perfect for professionals','Very Good',NULL,17,'Dell','XPS 15 9530',2023,0,'Intel Core i7-13700H',32,1000,15.6,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(3,'Gaming Laptop ASUS ROG','High-performance gaming laptop with RTX 4070','New',NULL,16,'ASUS','ROG Strix G16',2024,0,'Intel Core i9-13980HX',32,1000,16.0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL),(4,'iPhone 15 Pro Max','Apple iPhone 15 Pro Max 256GB, Natural Titanium','New',NULL,9,'Apple','iPhone 15 Pro Max',2023,0,NULL,NULL,NULL,NULL,'Unlocked','256GB','Natural Titanium',NULL,NULL,NULL,NULL,NULL),(5,'Samsung Galaxy S24 Ultra','Samsung flagship with S Pen, Titanium Black','Like New',NULL,9,'Samsung','Galaxy S24 Ultra',2024,0,NULL,NULL,NULL,NULL,'Unlocked','512GB','Titanium Black',NULL,NULL,NULL,NULL,NULL),(6,'Sony WH-1000XM5','Industry-leading noise cancelling headphones','New',NULL,11,'Sony','WH-1000XM5',2023,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Wireless',NULL,30,NULL,NULL),(7,'AirPods Pro 2nd Gen','Apple AirPods Pro with USB-C charging case','Like New',NULL,12,'Apple','AirPods Pro 2',2023,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Wireless',NULL,6,NULL,NULL),(8,'PlayStation 5','Sony PS5 Disc Edition with 2 controllers','Very Good',NULL,14,'Sony','PlayStation 5',2022,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'PlayStation','USA'),(9,'Nintendo Switch OLED','Nintendo Switch OLED Model White','New',NULL,14,'Nintendo','Switch OLED',2023,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Nintendo','USA');
/*!40000 ALTER TABLE `Item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Notification`
--

DROP TABLE IF EXISTS `Notification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Notification` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(15) NOT NULL,
  `message` text NOT NULL,
  `auction_id` int DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  KEY `auction_id` (`auction_id`),
  CONSTRAINT `notification_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `notification_ibfk_2` FOREIGN KEY (`auction_id`) REFERENCES `Auction` (`auction_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Notification`
--

LOCK TABLES `Notification` WRITE;
/*!40000 ALTER TABLE `Notification` DISABLE KEYS */;
/*!40000 ALTER TABLE `Notification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Question`
--

DROP TABLE IF EXISTS `Question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Question` (
  `question_id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(15) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `message` text NOT NULL,
  `response` text,
  `responded_by` varchar(15) DEFAULT NULL,
  `is_resolved` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`question_id`),
  KEY `user_id` (`user_id`),
  KEY `responded_by` (`responded_by`),
  CONSTRAINT `question_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `User` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `question_ibfk_2` FOREIGN KEY (`responded_by`) REFERENCES `CustomerRep` (`emp_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Question`
--

LOCK TABLES `Question` WRITE;
/*!40000 ALTER TABLE `Question` DISABLE KEYS */;
/*!40000 ALTER TABLE `Question` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Sale`
--

DROP TABLE IF EXISTS `Sale`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Sale` (
  `sale_id` int NOT NULL AUTO_INCREMENT,
  `auction_id` int NOT NULL,
  `item_id` int NOT NULL,
  `buyer_id` varchar(15) NOT NULL,
  `seller_id` varchar(15) NOT NULL,
  `final_price` decimal(12,2) NOT NULL,
  `shipping_address` text NOT NULL,
  `payment_card` varchar(20) NOT NULL,
  `sale_date` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sale_id`),
  KEY `auction_id` (`auction_id`),
  KEY `item_id` (`item_id`),
  KEY `buyer_id` (`buyer_id`),
  KEY `seller_id` (`seller_id`),
  CONSTRAINT `sale_ibfk_1` FOREIGN KEY (`auction_id`) REFERENCES `Auction` (`auction_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `sale_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `Item` (`item_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `sale_ibfk_3` FOREIGN KEY (`buyer_id`) REFERENCES `Buyer` (`buyer_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `sale_ibfk_4` FOREIGN KEY (`seller_id`) REFERENCES `Seller` (`seller_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Sale`
--

LOCK TABLES `Sale` WRITE;
/*!40000 ALTER TABLE `Sale` DISABLE KEYS */;
/*!40000 ALTER TABLE `Sale` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Seller`
--

DROP TABLE IF EXISTS `Seller`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Seller` (
  `seller_id` varchar(15) NOT NULL,
  `earnings` decimal(12,2) DEFAULT '0.00',
  `rating` decimal(3,2) DEFAULT '0.00',
  `total_ratings` int DEFAULT '0',
  PRIMARY KEY (`seller_id`),
  CONSTRAINT `seller_ibfk_1` FOREIGN KEY (`seller_id`) REFERENCES `User` (`user_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Seller`
--

LOCK TABLES `Seller` WRITE;
/*!40000 ALTER TABLE `Seller` DISABLE KEYS */;
INSERT INTO `Seller` VALUES ('seller1',0.00,4.50,10),('user1',0.00,4.80,5);
/*!40000 ALTER TABLE `Seller` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Staff`
--

DROP TABLE IF EXISTS `Staff`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Staff` (
  `emp_id` varchar(15) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`emp_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Staff`
--

LOCK TABLES `Staff` WRITE;
/*!40000 ALTER TABLE `Staff` DISABLE KEYS */;
INSERT INTO `Staff` VALUES ('admin','admin123','admin@buyme.com','555-0001','System','Administrator','1990-01-01','2025-12-01 02:41:07'),('rep1','rep123','rep1@buyme.com','555-0002','John','Smith','1992-05-15','2025-12-01 02:41:07');
/*!40000 ALTER TABLE `Staff` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `User`
--

DROP TABLE IF EXISTS `User`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `User` (
  `user_id` varchar(15) NOT NULL,
  `password` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `dob` date NOT NULL,
  `date_created` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `User`
--

LOCK TABLES `User` WRITE;
/*!40000 ALTER TABLE `User` DISABLE KEYS */;
INSERT INTO `User` VALUES ('admin','admin123','admin@example.com','0000000000','Admin','User','2000-01-01','2025-12-01 15:09:25',1),('buyer1','pass123','buyer1@email.com','555-1001','Alice','Johnson','1995-03-20','2025-12-01 02:41:07',1),('rep1','rep123','rep@example.com','3333333333','Rep','User','2000-01-01','2025-12-01 15:11:36',1),('seller1','pass123','seller1@email.com','555-1002','Bob','Williams','1988-07-12','2025-12-01 02:41:07',1),('user1','pass123','user1@email.com','555-1003','Carol','Davis','1990-11-08','2025-12-01 02:41:07',1);
/*!40000 ALTER TABLE `User` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-01 15:19:34
