-- Group 24: Krish Lenka, Matsvei Liapich, Sonia Kanchi


--DROP DATABASE IF EXISTS dbproject;
--CREATE DATABASE dbproject;
--USE dbproject;

-- Admin and Customer Rep tables
CREATE TABLE Staff(
	emp_ID varchar(15) PRIMARY KEY NOT NULL,
	password varchar(100) NOT NULL,
	email varchar(100) NOT NULL,
	phone varchar(20) NOT NULL,
	F_Name varchar(50) NOT NULL,
	L_Name varchar(50) NOT NULL,
	dob date NOT NULL,
	date_created datetime NOT NULL
);

-- Admin table
CREATE TABLE Admin(
	emp_ID varchar(15) PRIMARY KEY NOT NULL,
	FOREIGN KEY(emp_ID) 
		REFERENCES Staff(emp_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Customer Rep table
CREATE TABLE Customer_rep(
	emp_ID varchar(15) PRIMARY KEY NOT NULL,
	FOREIGN KEY(emp_ID) 
		REFERENCES Staff(emp_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Relationship between Admin and Customer Rep
CREATE TABLE Create_account_for(
	admin_ID varchar(15) NOT NULL,
	customer_rep_ID varchar(15) NOT NULL,
	PRIMARY KEY(admin_ID, customer_rep_ID),
	FOREIGN KEY(admin_ID) 
		REFERENCES Admin(emp_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(customer_rep_ID) 
		REFERENCES Customer_rep(emp_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Ticket table
CREATE TABLE Ticket(
	ticket_id int PRIMARY KEY NOT NULL,
	text text NOT NULL,
	created_date datetime NOT NULL,
	is_closed boolean NOT NULL
);

-- User table
CREATE TABLE User(
	user_id varchar(15) PRIMARY KEY NOT NULL,
	password varchar(100) NOT NULL,
	email varchar(100) NOT NULL,
	phone varchar(20) NOT NULL,
	F_Name varchar(50) NOT NULL,
	L_Name varchar(50) NOT NULL,
	dob date NOT NULL,
	date_created date NOT NULL
);

-- Buyer table
CREATE TABLE Buyer(
	buyer_ID varchar(15) PRIMARY KEY NOT NULL,
	shipping_address text NOT NULL,
	default_card varchar(20) NOT NULL,
	FOREIGN KEY(buyer_ID) 
		REFERENCES User(user_id)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Seller table
CREATE TABLE Seller(
	seller_ID varchar(15) PRIMARY KEY NOT NULL,
	earnings float NOT NULL,
	rating int NOT NULL,
	FOREIGN KEY(seller_ID) 
		REFERENCES User(user_id)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Bid table
CREATE TABLE Bid(
	bid_ID int NOT NULL,
	buyer_ID varchar(15) NOT NULL,
	auction_ID int NOT NULL,
	bid_amount float NOT NULL,
	bid_time datetime NOT NULL,
	is_autobid boolean NOT NULL,
	max_bid float, -- Made this nullable because max bid is only used for autobids
	PRIMARY KEY(bid_ID, auction_ID),
	FOREIGN KEY(buyer_ID) 
		REFERENCES Buyer(buyer_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(auction_ID) 
		REFERENCES Auction(auction_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
);

-- Auction table
CREATE TABLE Auction(
	auction_ID int PRIMARY KEY NOT NULL,
	auction_date datetime NOT NULL,
	close_date datetime,
	initial_price float NOT NULL,
	increment_price float NOT NULL,
	min_price float NOT NULL,
	seller_ID varchar(15) NOT NULL,
	highest_bid float NOT NULL, -- not sure how to make this a derived attribute
	FOREIGN KEY(seller_ID) 
		REFERENCES Seller(seller_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Item table
CREATE TABLE Item(
	item_id int PRIMARY KEY NOT NULL,
	item_title varchar(100) NOT NULL,
	item_description text NOT NULL,
	item_condition text NOT NULL,
	image_url text NOT NULL,
	category_id int NOT NULL,
	FOREIGN KEY(category_id) 
		REFERENCES Category(category_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Category table
CREATE TABLE Category(
	category_id int PRIMARY KEY NOT NULL,
	category_description text NOT NULL,
	category_title varchar(100) NOT NULL,
	parent_id int, -- self reference can be null
);

-- Alert table
CREATE TABLE Alert(
	alert_id int PRIMARY KEY NOT NULL,
	category_id int NOT NULL,
	buyer_id varchar(15) NOT NULL,
	--created_id?
	is_active boolean NOT NULL,
	FOREIGN KEY(category_id) 
		REFERENCES Category(category_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(buyer_id) 
		REFERENCES Buyer(buyer_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE
);

-- Sales table, this covers the part of the assignment about admins being able to generate summary sales reports
CREATE TABLE Sales(
	sale_id int PRIMARY KEY NOT NULL,
	auction_id int, -- nullable if sale doesn't come from auction
	item_id int, -- nullable if sale doesn't come directly from an item
	final_price float NOT NULL,
	sale_date datetime NOT NULL,
	buyer_id varchar(15) NOT NULL,
	seller_id varchar(15) NOT NULL,
	shipping_address text NOT NULL,
	default_card varchar(20) NOT NULL,
	shipping_cost float NOT NULL,
	admin_id varchar(15) NOT NULL,
	FOREIGN KEY(buyer_id) 
		REFERENCES Buyer(buyer_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(auction_id) 
		REFERENCES Auction(auction_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(item_id) 
		REFERENCES Item(item_id)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(seller_id) 
		REFERENCES Seller(seller_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
	FOREIGN KEY(admin_id) 
		REFERENCES Admin(emp_ID)
			ON DELETE CASCADE 
			ON UPDATE CASCADE,
);