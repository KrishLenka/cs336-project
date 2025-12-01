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

## Setup Instructions

### 1. Database Setup
1. Install MySQL Server
2. Run the schema file to create the database:
   ```sql
   source Group24_schema.sql
   ```
3. Update database credentials in `webapp/WEB-INF/classes/db/ApplicationDB.java` if needed

### 2. Tomcat Setup
1. Install Apache Tomcat 9.x
2. Copy the `webapp` folder to Tomcat's `webapps` directory
3. Rename to desired context name (e.g., `buyme`)
4. Compile the Java file:
   ```bash
   cd webapp/WEB-INF/classes
   javac -cp "../lib/*" db/ApplicationDB.java
   ```
   Or use the included pre-compiled .class file

### 3. Running the Application
1. Start MySQL server
2. Start Tomcat server
3. Access the application at: `http://localhost:8080/buyme/`

## Login Credentials

### Administrator
- **Username:** `admin`
- **Password:** `admin123`
- **Login as:** Administrator

### Customer Representative
- **Username:** `rep1`
- **Password:** `rep123`
- **Login as:** Customer Representative

### Test Users
- **Buyer:** `buyer1` / `pass123`
- **Seller:** `seller1` / `pass123`
- **Both:** `user1` / `pass123`

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

## Notes
- All prices are in USD
- Auctions auto-close at their end time
- Reserve prices (minimum prices) are kept secret from bidders
- Automatic bidding will bid the minimum amount needed to stay in the lead, up to your maximum
- User names are anonymized in bid history to protect privacy

