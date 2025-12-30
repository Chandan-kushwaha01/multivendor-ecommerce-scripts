-- Seed Data for Users
INSERT INTO
    Users (
        email,
        password_hash,
        role,
        first_name,
        last_name,
        phone_number,
        address_line1,
        city,
        country
    )
VALUES (
        'superadmin@example.com',
        'hashed_password_superadmin_1',
        'super_admin',
        'Admin',
        'Root',
        '9801234567',
        '123 Main St',
        'Kathmandu',
        'Nepal'
    ),
    (
        'vendor1@example.com',
        'hashed_password_vendor_1',
        'vendor',
        'Hari',
        'Sharma',
        '9812345678',
        '456 Shop Rd',
        'Pokhara',
        'Nepal'
    ),
    (
        'vendor2@example.com',
        'hashed_password_vendor_2',
        'vendor',
        'Sita',
        'Dahal',
        '9823456789',
        '789 Market Blvd',
        'Butwal',
        'Nepal'
    ),
    (
        'customer1@example.com',
        'hashed_password_customer_1',
        'customer',
        'Ram',
        'Thapa',
        '9834567890',
        '101 Home Ln',
        'Kathmandu',
        'Nepal'
    ),
    (
        'customer2@example.com',
        'hashed_password_customer_2',
        'customer',
        'Gita',
        'Rai',
        '9845678901',
        '202 Apartment Ct',
        'Lalitpur',
        'Nepal'
    );

-- Seed Data for Vendors
INSERT INTO
    Vendors (
        user_id,
        shop_name,
        shop_description,
        status,
        bank_account_name,
        bank_account_number,
        bank_name
    )
VALUES (
        (
            SELECT id
            FROM Users
            WHERE
                email = 'vendor1@example.com'
        ),
        'Hari Mobiles',
        'Your one-stop shop for mobile phones and accessories.',
        'approved',
        'Hari Sharma',
        '1234567890',
        'Nepal Bank Ltd.'
    ),
    (
        (
            SELECT id
            FROM Users
            WHERE
                email = 'vendor2@example.com'
        ),
        'Sita Fashion',
        'Trendy clothing and accessories for all.',
        'approved',
        'Sita Dahal',
        '0987654321',
        'Everest Bank Ltd.'
    );

-- Seed Data for Categories
INSERT INTO
    Categories (name, description)
VALUES (
        'Electronics',
        'Gadgets and electronic devices'
    ),
    (
        'Mobile Phones',
        'Smartphones and feature phones'
    ),
    (
        'Accessories',
        'Chargers, headphones, cases'
    ),
    (
        'Fashion',
        'Apparel and clothing'
    ),
    (
        'Men''s Fashion',
        'Clothing for men'
    ),
    (
        'Women''s Fashion',
        'Clothing for women'
    );

-- Establish Parent Categories
UPDATE Categories
SET
    parent_category_id = (
        SELECT id
        FROM (
                SELECT id
                FROM Categories
                WHERE
                    name = 'Electronics'
            ) AS temp
    )
WHERE
    name IN (
        'Mobile Phones',
        'Accessories'
    );

UPDATE Categories
SET
    parent_category_id = (
        SELECT id
        FROM (
                SELECT id
                FROM Categories
                WHERE
                    name = 'Fashion'
            ) AS temp
    )
WHERE
    name IN (
        'Men''s Fashion',
        'Women''s Fashion'
    );

-- Seed Data for Products
INSERT INTO
    Products (
        vendor_id,
        category_id,
        name,
        description,
        price,
        stock_quantity,
        image_urls,
        status
    )
VALUES (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Hari Mobiles'
        ),
        (
            SELECT id
            FROM Categories
            WHERE
                name = 'Mobile Phones'
        ),
        'Smartphone X',
        'Latest model with advanced features.',
        50000.00,
        10,
        '["http://example.com/img/phone-x-1.jpg", "http://example.com/img/phone-x-2.jpg"]',
        'active'
    ),
    (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Hari Mobiles'
        ),
        (
            SELECT id
            FROM Categories
            WHERE
                name = 'Accessories'
        ),
        'Wireless Earbuds',
        'High-quality sound with long battery life.',
        3500.00,
        50,
        '["http://example.com/img/earbuds-1.jpg"]',
        'active'
    ),
    (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        (
            SELECT id
            FROM Categories
            WHERE
                name = 'Women''s Fashion'
        ),
        'Floral Summer Dress',
        'Light and comfortable floral dress for summer.',
        2500.00,
        20,
        '["http://example.com/img/dress-1.jpg", "http://example.com/img/dress-2.jpg"]',
        'active'
    ),
    (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        (
            SELECT id
            FROM Categories
            WHERE
                name = 'Men''s Fashion'
        ),
        'Casual Denim Shirt',
        'Stylish denim shirt for men.',
        1800.00,
        30,
        '["http://example.com/img/denim-shirt-1.jpg"]',
        'active'
    );

-- Seed Data for Orders
INSERT INTO
    Orders (
        customer_id,
        total_amount,
        status,
        shipping_address_line1,
        shipping_city,
        shipping_country,
        payment_status
    )
VALUES (
        (
            SELECT id
            FROM Users
            WHERE
                email = 'customer1@example.com'
        ),
        50000.00,
        'delivered',
        '101 Home Ln',
        'Kathmandu',
        'Nepal',
        'paid'
    ),
    (
        (
            SELECT id
            FROM Users
            WHERE
                email = 'customer2@example.com'
        ),
        2500.00,
        'processing',
        '202 Apartment Ct',
        'Lalitpur',
        'Nepal',
        'pending'
    ),
    (
        (
            SELECT id
            FROM Users
            WHERE
                email = 'customer1@example.com'
        ),
        1800.00,
        'shipped',
        '101 Home Ln',
        'Kathmandu',
        'Nepal',
        'paid'
    );

-- Seed Data for OrderItems
INSERT INTO
    OrderItems (
        order_id,
        product_id,
        vendor_id,
        quantity,
        price_at_purchase
    )
VALUES (
        (
            SELECT id
            FROM Orders
            WHERE
                customer_id = (
                    SELECT id
                    FROM Users
                    WHERE
                        email = 'customer1@example.com'
                )
                AND total_amount = 50000.00
        ),
        (
            SELECT id
            FROM Products
            WHERE
                name = 'Smartphone X'
        ),
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Hari Mobiles'
        ),
        1,
        50000.00
    ),
    (
        (
            SELECT id
            FROM Orders
            WHERE
                customer_id = (
                    SELECT id
                    FROM Users
                    WHERE
                        email = 'customer2@example.com'
                )
                AND total_amount = 2500.00
        ),
        (
            SELECT id
            FROM Products
            WHERE
                name = 'Floral Summer Dress'
        ),
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        1,
        2500.00
    ),
    (
        (
            SELECT id
            FROM Orders
            WHERE
                customer_id = (
                    SELECT id
                    FROM Users
                    WHERE
                        email = 'customer1@example.com'
                )
                AND total_amount = 1800.00
        ),
        (
            SELECT id
            FROM Products
            WHERE
                name = 'Casual Denim Shirt'
        ),
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        1,
        1800.00
    );

-- Seed Data for Payments
INSERT INTO
    Payments (
        order_id,
        payment_method,
        transaction_id,
        amount,
        currency,
        status
    )
VALUES (
        (
            SELECT id
            FROM Orders
            WHERE
                customer_id = (
                    SELECT id
                    FROM Users
                    WHERE
                        email = 'customer1@example.com'
                )
                AND total_amount = 50000.00
        ),
        'Esewa',
        'TRX123456789',
        50000.00,
        'NPR',
        'success'
    ),
    (
        (
            SELECT id
            FROM Orders
            WHERE
                customer_id = (
                    SELECT id
                    FROM Users
                    WHERE
                        email = 'customer1@example.com'
                )
                AND total_amount = 1800.00
        ),
        'Khalti',
        'TRX987654321',
        1800.00,
        'NPR',
        'success'
    );

-- Seed Data for Commissions (assuming 10% commission rate)
INSERT INTO
    Commissions (
        vendor_id,
        order_item_id,
        commission_rate,
        commission_amount,
        status
    )
VALUES (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Hari Mobiles'
        ),
        (
            SELECT id
            FROM OrderItems
            WHERE
                product_id = (
                    SELECT id
                    FROM Products
                    WHERE
                        name = 'Smartphone X'
                )
        ),
        0.10,
        5000.00,
        'due'
    ),
    (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        (
            SELECT id
            FROM OrderItems
            WHERE
                product_id = (
                    SELECT id
                    FROM Products
                    WHERE
                        name = 'Floral Summer Dress'
                )
        ),
        0.10,
        250.00,
        'due'
    ),
    (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Sita Fashion'
        ),
        (
            SELECT id
            FROM OrderItems
            WHERE
                product_id = (
                    SELECT id
                    FROM Products
                    WHERE
                        name = 'Casual Denim Shirt'
                )
        ),
        0.10,
        180.00,
        'due'
    );

-- Seed Data for Reviews
INSERT INTO
    Reviews (
        product_id,
        customer_id,
        rating,
        review_text
    )
VALUES (
        (
            SELECT id
            FROM Products
            WHERE
                name = 'Smartphone X'
        ),
        (
            SELECT id
            FROM Users
            WHERE
                email = 'customer1@example.com'
        ),
        5,
        'Absolutely love this phone! Great camera and battery life.'
    ),
    (
        (
            SELECT id
            FROM Products
            WHERE
                name = 'Floral Summer Dress'
        ),
        (
            SELECT id
            FROM Users
            WHERE
                email = 'customer2@example.com'
        ),
        4,
        'Very pretty dress, fits well. Fast delivery.'
    );

-- Seed Data for VendorPayouts
-- Assuming Hari Mobiles had 5000 in commission due, and it's being paid out
INSERT INTO
    VendorPayouts (
        vendor_id,
        amount,
        status,
        transaction_id,
        notes
    )
VALUES (
        (
            SELECT id
            FROM Vendors
            WHERE
                shop_name = 'Hari Mobiles'
        ),
        5000.00,
        'completed',
        'PAYOUT_HARIMOB_001',
        'Monthly commission payout for Hari Mobiles.'
    );
