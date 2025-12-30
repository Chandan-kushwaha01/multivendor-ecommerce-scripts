I can't generate the full SQL and Prisma scripts for a multi-vendor e-commerce website based solely on the image provided. The image outlines the features and packages, but doesn't contain the detailed database schema or application logic needed for generating complete scripts.

However, I can provide you with a basic conceptual schema for a multi-vendor e-commerce platform that you can adapt for both SQL and Prisma.

Conceptual Database Schema for a Multi-Vendor E-commerce Website

Here's a breakdown of the core entities and their relationships:

Users:

id (PK)

email (Unique)

password

role (e.g., 'Super Admin', 'Admin', 'Vendor', 'Customer')

name

address

phone_number

created_at

updated_at

Vendors: (Extends Users, or has a one-to-one relationship with Users)

id (PK)

user_id (FK to Users.id)

shop_name (Unique)

shop_description

status (e.g., 'pending', 'approved', 'rejected')

bank_account_details (sensitive, consider encryption)

created_at

updated_at

Categories:

id (PK)

name (Unique)

description

parent_category_id (Self-referencing FK for subcategories)

created_at

updated_at

Products:

id (PK)

vendor_id (FK to Vendors.id)

category_id (FK to Categories.id)

name

description

price

stock_quantity

image_urls (Array or JSON field, or a separate ProductImages table)

status (e.g., 'active', 'inactive', 'draft')

created_at

updated_at

Orders:

id (PK)

customer_id (FK to Users.id where role is 'Customer')

order_date

total_amount

status (e.g., 'pending', 'processing', 'shipped', 'delivered', 'cancelled')

shipping_address

payment_status (e.g., 'pending', 'paid', 'refunded')

created_at

updated_at

OrderItems: (Junction table for Orders and Products)

id (PK)

order_id (FK to Orders.id)

product_id (FK to Products.id)

quantity

price_at_purchase

vendor_id (FK to Vendors.id - useful for splitting orders by vendor)

Payments:

id (PK)

order_id (FK to Orders.id)

payment_method (e.g., 'credit_card', 'paypal', 'stripe')

transaction_id (from payment gateway)

amount

currency

status (e.g., 'success', 'failed', 'pending')

created_at

Commissions: (For tracking vendor commissions)

id (PK)

vendor_id (FK to Vendors.id)

order_item_id (FK to OrderItems.id)

commission_rate

commission_amount

status (e.g., 'due', 'paid')

created_at

updated_at

Reviews & Ratings:

id (PK)

product_id (FK to Products.id)

customer_id (FK to Users.id)

rating (1-5)

review_text

created_at

Vendor Payouts:

id (PK)

vendor_id (FK to Vendors.id)

amount

payout_date

status (e.g., 'pending', 'completed', 'failed')

transaction_id (if applicable)

created_at

Example SQL Schema (MySQL/PostgreSQL Syntax)

code
SQL
download
content_copy
expand_less
-- Users Table
CREATE TABLE Users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL, -- Store hashed passwords
    role ENUM('super_admin', 'admin', 'vendor', 'customer') NOT NULL DEFAULT 'customer',
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    phone_number VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Vendors Table
CREATE TABLE Vendors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE NOT NULL, -- One-to-one with a User
    shop_name VARCHAR(255) UNIQUE NOT NULL,
    shop_description TEXT,
    status ENUM('pending', 'approved', 'rejected') NOT NULL DEFAULT 'pending',
    bank_account_name VARCHAR(255),
    bank_account_number VARCHAR(255),
    bank_name VARCHAR(255),
    bank_swift_code VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- Categories Table
CREATE TABLE Categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_category_id) REFERENCES Categories(id) ON DELETE SET NULL
);

-- Products Table
CREATE TABLE Products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    image_urls JSON, -- Store array of URLs as JSON string
    status ENUM('active', 'inactive', 'draft') NOT NULL DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(id) ON DELETE RESTRICT
);

-- Orders Table
CREATE TABLE Orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_city VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_country VARCHAR(100),
    payment_status ENUM('pending', 'paid', 'refunded', 'failed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES Users(id) ON DELETE RESTRICT
);

-- OrderItems Table
CREATE TABLE OrderItems (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    vendor_id INT NOT NULL, -- Denormalized for easier vendor-specific order views
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(id) ON DELETE RESTRICT,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(id) ON DELETE RESTRICT
);

-- Payments Table
CREATE TABLE Payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50),
    transaction_id VARCHAR(255) UNIQUE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'NPR', -- As per your budget
    status ENUM('success', 'failed', 'pending', 'refunded') NOT NULL DEFAULT 'pending',
    gateway_response TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES Orders(id) ON DELETE RESTRICT
);

-- Commissions Table
CREATE TABLE Commissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    order_item_id INT NOT NULL,
    commission_rate DECIMAL(5, 4) NOT NULL, -- e.g., 0.10 for 10%
    commission_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('due', 'paid', 'cancelled') NOT NULL DEFAULT 'due',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES OrderItems(id) ON DELETE CASCADE
);

-- Reviews Table
CREATE TABLE Reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES Products(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES Users(id) ON DELETE CASCADE
);

-- VendorPayouts Table
CREATE TABLE VendorPayouts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    vendor_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payout_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    transaction_id VARCHAR(255), -- From bank or payment service
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vendor_id) REFERENCES Vendors(id) ON DELETE RESTRICT
);

Example Prisma Schema (schema.prisma)

code
Prisma
download
content_copy
expand_less
// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "mysql" // or "postgresql", "sqlite", "sqlserver"
  url      = env("DATABASE_URL")
}

enum UserRole {
  SUPER_ADMIN
  ADMIN
  VENDOR
  CUSTOMER
}

enum VendorStatus {
  PENDING
  APPROVED
  REJECTED
}

enum ProductStatus {
  ACTIVE
  INACTIVE
  DRAFT
}

enum OrderStatus {
  PENDING
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
}

enum PaymentStatus {
  PENDING
  PAID
  REFUNDED
  FAILED
}

enum CommissionStatus {
  DUE
  PAID
  CANCELLED
}

enum PayoutStatus {
  PENDING
  COMPLETED
  FAILED
}


model User {
  id               Int       @id @default(autoincrement())
  email            String    @unique
  passwordHash     String    @map("password_hash")
  role             UserRole  @default(CUSTOMER)
  firstName        String?   @map("first_name")
  lastName         String?   @map("last_name")
  phoneNumber      String?   @map("phone_number")
  addressLine1     String?   @map("address_line1")
  addressLine2     String?   @map("address_line2")
  city             String?
  state            String?
  postalCode       String?   @map("postal_code")
  country          String?
  createdAt        DateTime  @default(now()) @map("created_at")
  updatedAt        DateTime  @updatedAt @map("updated_at")

  vendor           Vendor?
  orders           Order[]
  reviews          Review[]

  @@map("Users")
}

model Vendor {
  id                   Int          @id @default(autoincrement())
  userId               Int          @unique @map("user_id")
  shopName             String       @unique @map("shop_name")
  shopDescription      String?      @map("shop_description")
  status               VendorStatus @default(PENDING)
  bankAccountName      String?      @map("bank_account_name")
  bankAccountNumber    String?      @map("bank_account_number")
  bankName             String?      @map("bank_name")
  bankSwiftCode        String?      @map("bank_swift_code")
  createdAt            DateTime     @default(now()) @map("created_at")
  updatedAt            DateTime     @updatedAt @map("updated_at")

  user                 User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  products             Product[]
  orderItems           OrderItem[]
  commissions          Commission[]
  payouts              VendorPayout[]

  @@map("Vendors")
}

model Category {
  id                 Int        @id @default(autoincrement())
  name               String     @unique
  description        String?
  parentCategoryId   Int?       @map("parent_category_id")
  createdAt          DateTime   @default(now()) @map("created_at")
  updatedAt          DateTime   @updatedAt @map("updated_at")

  parentCategory     Category?  @relation("Subcategories", fields: [parentCategoryId], references: [id])
  subcategories      Category[] @relation("Subcategories")
  products           Product[]

  @@map("Categories")
}

model Product {
  id             Int          @id @default(autoincrement())
  vendorId       Int          @map("vendor_id")
  categoryId     Int          @map("category_id")
  name           String
  description    String?
  price          Decimal      @db.Decimal(10, 2)
  stockQuantity  Int          @default(0) @map("stock_quantity")
  imageUrls      Json?        @map("image_urls") // Store array of URLs as JSON
  status         ProductStatus @default(DRAFT)
  createdAt      DateTime     @default(now()) @map("created_at")
  updatedAt      DateTime     @updatedAt @map("updated_at")

  vendor         Vendor       @relation(fields: [vendorId], references: [id], onDelete: Cascade)
  category       Category     @relation(fields: [categoryId], references: [id])
  orderItems     OrderItem[]
  reviews        Review[]

  @@map("Products")
}

model Order {
  id                    Int          @id @default(autoincrement())
  customerId            Int          @map("customer_id")
  orderDate             DateTime     @default(now()) @map("order_date")
  totalAmount           Decimal      @db.Decimal(10, 2) @map("total_amount")
  status                OrderStatus  @default(PENDING)
  shippingAddressLine1  String?      @map("shipping_address_line1")
  shippingAddressLine2  String?      @map("shipping_address_line2")
  shippingCity          String?      @map("shipping_city")
  shippingState         String?      @map("shipping_state")
  shippingPostalCode    String?      @map("shipping_postal_code")
  shippingCountry       String?      @map("shipping_country")
  paymentStatus         PaymentStatus @default(PENDING) @map("payment_status")
  createdAt             DateTime     @default(now()) @map("created_at")
  updatedAt             DateTime     @updatedAt @map("updated_at")

  customer              User         @relation(fields: [customerId], references: [id])
  orderItems            OrderItem[]
  payments              Payment[]

  @@map("Orders")
}

model OrderItem {
  id                 Int       @id @default(autoincrement())
  orderId            Int       @map("order_id")
  productId          Int       @map("product_id")
  vendorId           Int       @map("vendor_id")
  quantity           Int
  priceAtPurchase    Decimal   @db.Decimal(10, 2) @map("price_at_purchase")
  createdAt          DateTime  @default(now()) @map("created_at")

  order              Order     @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product            Product   @relation(fields: [productId], references: [id])
  vendor             Vendor    @relation(fields: [vendorId], references: [id])
  commissions        Commission[]

  @@map("OrderItems")
}

model Payment {
  id              Int         @id @default(autoincrement())
  orderId         Int         @map("order_id")
  paymentMethod   String?     @map("payment_method")
  transactionId   String      @unique @map("transaction_id")
  amount          Decimal     @db.Decimal(10, 2)
  currency        String      @default("NPR")
  status          PaymentStatus @default(PENDING)
  gatewayResponse String?     @db.Text @map("gateway_response")
  createdAt       DateTime    @default(now()) @map("created_at")

  order           Order       @relation(fields: [orderId], references: [id])

  @@map("Payments")
}

model Commission {
  id               Int            @id @default(autoincrement())
  vendorId         Int            @map("vendor_id")
  orderItemId      Int            @map("order_item_id")
  commissionRate   Decimal        @db.Decimal(5, 4) @map("commission_rate")
  commissionAmount Decimal        @db.Decimal(10, 2) @map("commission_amount")
  status           CommissionStatus @default(DUE)
  createdAt        DateTime       @default(now()) @map("created_at")
  updatedAt        DateTime       @updatedAt @map("updated_at")

  vendor           Vendor         @relation(fields: [vendorId], references: [id], onDelete: Cascade)
  orderItem        OrderItem      @relation(fields: [orderItemId], references: [id], onDelete: Cascade)

  @@map("Commissions")
}

model Review {
  id          Int      @id @default(autoincrement())
  productId   Int      @map("product_id")
  customerId  Int      @map("customer_id")
  rating      Int      @db.Int
  reviewText  String?  @db.Text @map("review_text")
  createdAt   DateTime @default(now()) @map("created_at")

  product     Product  @relation(fields: [productId], references: [id], onDelete: Cascade)
  customer    User     @relation(fields: [customerId], references: [id], onDelete: Cascade)

  @@map("Reviews")
}

model VendorPayout {
  id            Int        @id @default(autoincrement())
  vendorId      Int        @map("vendor_id")
  amount        Decimal    @db.Decimal(10, 2)
  payoutDate    DateTime   @default(now()) @map("payout_date")
  status        PayoutStatus @default(PENDING)
  transactionId String?    @unique @map("transaction_id")
  notes         String?    @db.Text
  createdAt     DateTime   @default(now()) @map("created_at")

  vendor        Vendor     @relation(fields: [vendorId], references: [id])

  @@map("VendorPayouts")
}

Next Steps for Implementation:

Refine Schema: Review the provided schema and adjust it based on your exact requirements and the specific details of your project. For instance, you might need more fields for Users (e.g., shipping defaults), Products (e.g., weight, dimensions), or Vendors (e.g., tax info).

Database Choice: Decide between MySQL, PostgreSQL, or another SQL database. The provided SQL is largely compatible but might require minor syntax adjustments for specific databases.

Prisma Setup: If using Prisma, install it in your project (npm install prisma --save-dev or yarn add prisma --dev) and then run npx prisma db push (for development) or npx prisma migrate dev to apply the schema to your database.

Application Logic: This schema is just the foundation. You'll need to build your application logic (e.g., API endpoints, authentication, business rules) using a backend framework (Node.js with Express, Python with Django/Flask, etc.) to interact with the database using SQL queries or Prisma Client.

Security: For production, ensure you implement proper security measures, especially for sensitive data like passwords (always hash them!) and banking details (encryption at rest).

Let me know if you have specific parts of the schema you'd like to dive deeper into, or if you want to explore how to handle specific features from your project proposal within this database structure!
