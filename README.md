

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
