

# Database Schema for a Multi-Vendor E-commerce Website

Here's a breakdown of the core entities and their relationships:

## Users:

* id (PK)

* email (Unique)

* password

* role (e.g., 'Super Admin', 'Admin', 'Vendor', 'Customer')

* name

* address

* phone_number

* created_at

* updated_at

## Vendors: (Extends Users, or has a one-to-one relationship with Users)

* id (PK)

* user_id (FK to Users.id)

* shop_name (Unique)

* shop_description

* status (e.g., 'pending', 'approved', 'rejected')

* bank_account_details (sensitive, consider encryption)

* created_at

* updated_at

## Categories:

* id (PK)

* name (Unique)

* description

* parent_category_id (Self-referencing FK for subcategories)

* created_at

* updated_at

## Products:

* id (PK)

* vendor_id (FK to Vendors.id)

* category_id (FK to Categories.id)

* name

* description

* price

* stock_quantity

* image_urls (Array or JSON field, or a separate ProductImages table)

* status (e.g., 'active', 'inactive', 'draft')

* created_at

* updated_at

## Orders:

* id (PK)

* customer_id (FK to Users.id where role is 'Customer')

* order_date

* total_amount

* status (e.g., 'pending', 'processing', 'shipped', 'delivered', 'cancelled')

* shipping_address

* payment_status (e.g., 'pending', 'paid', 'refunded')

* created_at

* updated_at

## OrderItems: (Junction table for Orders and Products)

* id (PK)

* order_id (FK to Orders.id)

* product_id (FK to Products.id)

* quantity

* price_at_purchase

* vendor_id (FK to Vendors.id - useful for splitting orders by vendor)

## Payments:

* id (PK)

* order_id (FK to Orders.id)

* payment_method (e.g., 'credit_card', 'paypal', 'stripe')

* transaction_id (from payment gateway)

* amount

* currency

* status (e.g., 'success', 'failed', 'pending')

* created_at

## Commissions: (For tracking vendor commissions)

* id (PK)

* vendor_id (FK to Vendors.id)

* order_item_id (FK to OrderItems.id)

* commission_rate

* commission_amount

* status (e.g., 'due', 'paid')

* created_at

* updated_at

## Reviews & Ratings:

* id (PK)

* product_id (FK to Products.id)

* customer_id (FK to Users.id)

* rating (1-5)

* review_text

* created_at

## Vendor Payouts:

* id (PK)

* vendor_id (FK to Vendors.id)

* amount

* payout_date

* status (e.g., 'pending', 'completed', 'failed')

* transaction_id (if applicable)

* created_at



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
