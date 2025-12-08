# BuyMe - Online Electronics Auction System

**CS 336 - Principles of Information and Data Management**  
**Fall 2025 - Group 24**

## Team Members
- Krish Lenka
- Matsvei Liapich
- Sonia Kanchi

## Project Description

BuyMe is an online auction platform specializing in **Electronics** with the following category hierarchy:
- **Computers** → Laptops, Desktops, Tablets → Gaming Laptops, Business Laptops, Ultrabooks
- **Phones** → Smartphones, Phone Accessories
- **Audio** → Headphones, Earbuds, Speakers
- **Gaming** → Consoles, Controllers

## Features Implemented

### End-User Features (Buyers & Sellers)
- ✅ User registration and account management (login/logout)
- ✅ Create and delete accounts
- ✅ Browse auctions by category with filters
- ✅ Advanced search with multiple criteria (keyword, category, price range, condition, brand, seller)
- ✅ Create auction listings with category-specific fields (computer specs, phone details, etc.)
- ✅ Place manual bids on auctions
- ✅ **Automatic bidding** - Set a maximum bid and the system bids incrementally for you
- ✅ Set alerts for items by category, brand, keywords, and price range
- ✅ View bid history for any auction
- ✅ View auctions participated in (as buyer or seller)
- ✅ View similar items (same category)
- ✅ Anonymized bidder names in bid history
- ✅ Notifications for outbid alerts and new matching items
- ✅ Submit questions to customer support

### Customer Representative Features
- ✅ View and manage user accounts
- ✅ Edit user information
- ✅ Reset user passwords
- ✅ Deactivate user accounts
- ✅ View and manage auctions
- ✅ Remove illegal/inappropriate auctions
- ✅ Remove individual bids
- ✅ Answer customer questions

### Administrator Features
- ✅ Create customer representative accounts
- ✅ Manage customer representative accounts
- ✅ **Sales Reports:**
  - Total earnings
  - Earnings per item
  - Earnings per item type (category)
  - Earnings per end-user (seller)
  - Best-selling items
  - Best buyers

## Technology Stack
- **Frontend:** HTML, CSS, JavaScript, JSP
- **Backend:** Java, JDBC
- **Database:** MySQL
- **Server:** Apache Tomcat

## Prerequisites
- **Java JDK 11+** (JDK 17 or 21 recommended)
- **MySQL 8.0+**
- **Apache Tomcat 9.x or later** (tested on Tomcat 9, 10, and 11)

## Setup Instructions

### 1. Database Setup

Start MySQL and load the schema:

```bash
# Connect to MySQL
mysql -u root -p

# Inside the MySQL prompt, run:
CREATE DATABASE IF NOT EXISTS cs336project;
USE cs336project;
SOURCE /full/path/to/Group24_schema.sql;
EXIT;
```

> **Note:** The schema file creates all tables and populates them with sample data.

**Configure database credentials** (if different from defaults):

Edit `webapp/WEB-INF/classes/db/ApplicationDB.java`:
```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/cs336project";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "password";  // Change this
```

If you modify the Java file, recompile it:
```bash
cd webapp/WEB-INF/classes
javac -cp "../lib/*" db/ApplicationDB.java
```

### 2. Deploy to Tomcat

Copy the `webapp` folder to Tomcat's `webapps` directory:

| Platform | Typical webapps location |
|----------|-------------------------|
| **macOS (Homebrew)** | `/opt/homebrew/opt/tomcat/libexec/webapps/` |
| **Linux (apt)** | `/var/lib/tomcat9/webapps/` |
| **Windows** | `C:\Program Files\Apache Software Foundation\Tomcat\webapps\` |

```bash
# Example for macOS:
cp -r webapp /opt/homebrew/opt/tomcat/libexec/webapps/buyme

# Example for Linux:
sudo cp -r webapp /var/lib/tomcat9/webapps/buyme
```

### 3. Start Services

**macOS (Homebrew):**
```bash
brew services start mysql
catalina start
```

**Linux (systemd):**
```bash
sudo systemctl start mysql
sudo systemctl start tomcat9
```

**Windows:**
- Start MySQL from Services or MySQL Workbench
- Run `startup.bat` in Tomcat's `bin` directory

### 4. Access the Application

Open your browser and navigate to:

**http://localhost:8080/buyme/**

## Login Credentials

| Role | Username | Password | Description |
|------|----------|----------|-------------|
| **Administrator** | `admin` | `admin123` | Full system access, manage reps, view reports |
| **Customer Rep** | `rep1` | `rep123` | Manage users, auctions, answer questions |
| **Buyer** | `buyer1` | `pass123` | Browse and bid on auctions |
| **Seller** | `seller1` | `pass123` | Create and manage auction listings |
| **Buyer & Seller** | `user1` | `pass123` | Both buying and selling capabilities |

## Project Structure
```
webapp/
├── css/                    # Stylesheets
├── js/                     # JavaScript files
├── includes/               # Header/footer components
├── admin/                  # Admin dashboard pages
├── rep/                    # Customer rep dashboard pages
├── WEB-INF/
│   ├── classes/db/         # Java database classes
│   ├── lib/                # MySQL connector JAR
│   └── web.xml             # Web application config
└── *.jsp                   # Main application pages
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **Database connection error** | Verify MySQL is running and credentials in `ApplicationDB.java` match your setup |
| **404 Not Found** | Ensure the webapp folder is named correctly in Tomcat's `webapps` directory |
| **Class not found errors** | Recompile `ApplicationDB.java` or verify `mysql-connector-java` JAR is in `WEB-INF/lib/` |
| **Port 8080 in use** | Stop other services using the port, or configure Tomcat to use a different port in `conf/server.xml` |

## Notes
- All prices are in USD
- Auctions auto-close at their end time
- Reserve prices (minimum prices) are kept secret from bidders
- Automatic bidding will bid the minimum amount needed to stay in the lead, up to your maximum
- User names are anonymized in bid history to protect privacy
