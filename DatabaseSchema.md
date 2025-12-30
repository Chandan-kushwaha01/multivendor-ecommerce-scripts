# Database Schema Diagram (ER Diagram)
Generating a visually appealing and accurate ER diagram directly in text is challenging. However, I can describe the relationships and entities clearly, and then provide an image generated from this conceptual model.
Entities (Tables):
--Users
--Vendors
--Categories
--Products
--Orders
--OrderItems
--Payments
--Commissions
--Reviews
--VendorPayouts

## Relationships:
### Users to Vendors:
One-to-one (User can be a Vendor, but not all Users are Vendors). Vendors user_id is a foreign key to Users id.
### Users to Orders:
One-to-many (User as a customer can place many Orders). Orders customer_id is a foreign key to Users id.
### Users to Reviews: 
One-to-many (User can write many Reviews). Reviews customer_id is a foreign key to Users id.
### Categories to Categories: 
One-to-many (Self-referencing for parent/subcategory structure). Categories parent_category_id is a foreign key to Categories id.
### Vendors to Products: 
One-to-many (Vendor can have many Products). Products vendor_id is a foreign key to Vendors id.
### Categories to Products: 
One-to-many (Category can have many Products). Products category_id is a foreign key to Categories id.
### Orders to OrderItems: 
One-to-many (Order has many OrderItems). OrderItems order_id is a foreign key to Orders id.
### Products to OrderItems: 
One-to-many (Product can be in many OrderItems). OrderItems product_id is a foreign key to Products id.
### Vendors to OrderItems: 
One-to-many (Vendor's products are in many OrderItems). OrderItems vendor_id is a foreign key to Vendors id. (Denormalized, as noted)
### Orders to Payments: 
One-to-many (Order can have many Payments if partially paid or retries, though often one-to-one for successful final payment). Payments order_id is a foreign key to Orders id.
### OrderItems to Commissions: 
One-to-one/many (OrderItem generates one Commission, but a Commission is related to one OrderItem). Commissions order_item_id is a foreign key to OrderItems id.
### Vendors to Commissions: 
One-to-many (Vendor receives many Commissions). Commissions vendor_id is a foreign key to Vendors id.
### Products to Reviews: 
One-to-many (Product can have many Reviews). Reviews product_id is a foreign key to Products id.
### Vendors to VendorPayouts:
One-to-many (Vendor receives many Payouts). VendorPayouts vendor_id is a foreign key to Vendors id.
