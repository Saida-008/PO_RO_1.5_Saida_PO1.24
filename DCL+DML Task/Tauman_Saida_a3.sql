CREATE SCHEMA IF NOT EXISTS restaurant;
SET search_path TO restaurant, public;

DROP USER IF EXISTS db_admin_user;
DROP USER IF EXISTS db_reader_user;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'restaurant_admin') THEN
        DROP OWNED BY restaurant_admin;
    END IF;
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'restaurant_readonly') THEN
        DROP OWNED BY restaurant_readonly;
    END IF;
END $$;

DROP ROLE IF EXISTS restaurant_admin;
DROP ROLE IF EXISTS restaurant_readonly;

CREATE ROLE restaurant_admin;
CREATE ROLE restaurant_readonly;

GRANT USAGE ON SCHEMA restaurant TO restaurant_admin;
GRANT USAGE ON SCHEMA restaurant TO restaurant_readonly;
GRANT USAGE ON SCHEMA public TO restaurant_admin;
GRANT USAGE ON SCHEMA public TO restaurant_readonly;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA restaurant TO restaurant_admin;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA restaurant TO restaurant_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA restaurant TO restaurant_readonly;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA restaurant TO restaurant_readonly;

CREATE USER db_admin_user WITH PASSWORD 'AdminSecure2026!';
CREATE USER db_reader_user WITH PASSWORD 'ReaderSecure2026!';

GRANT restaurant_admin TO db_admin_user;
GRANT restaurant_readonly TO db_reader_user;

ALTER USER db_admin_user SET search_path TO restaurant, public;
ALTER USER db_reader_user SET search_path TO restaurant, public;

REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA restaurant FROM restaurant_readonly;

/*
\dp restaurant.customer
                                            Access privileges
   Schema   |   Name   | Type  |           Access privileges           | Column privileges | Policies 
------------+----------+-------+---------------------------------------+-------------------+----------
 restaurant | customer | table | restaurant_admin=arwd/restaurant     +|                   | 
            |          |       | restaurant_readonly=r/restaurant      |                   | 
(1 row)
*/

CREATE TABLE IF NOT EXISTS restaurant.test_perm (
    id SERIAL PRIMARY KEY,
    val VARCHAR(50)
);
GRANT ALL ON restaurant.test_perm TO restaurant_admin;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE restaurant.test_perm_id_seq TO restaurant_admin;
GRANT SELECT ON restaurant.test_perm TO restaurant_readonly;

SET ROLE db_admin_user;
SELECT current_user;
SELECT count(*) FROM restaurant.test_perm;
INSERT INTO restaurant.test_perm (val) VALUES ('Admin Test') RETURNING *;
UPDATE restaurant.test_perm SET val = 'Admin Updated' WHERE val = 'Admin Test';
DELETE FROM restaurant.test_perm WHERE val = 'Admin Updated';
RESET ROLE;

SET ROLE db_reader_user;
SELECT current_user;
SELECT count(*) FROM restaurant.test_perm;

DO $$
BEGIN
    INSERT INTO restaurant.test_perm (val) VALUES ('Reader Test');
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'Expected INSERT failure caught';
END $$;

DO $$
BEGIN
    UPDATE restaurant.test_perm SET val = 'Reader Update';
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'Expected UPDATE failure caught';
END $$;


DO $$
BEGIN
    DELETE FROM restaurant.test_perm WHERE id = 1;
EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'Expected DELETE failure caught';
END $$;

RESET ROLE;
DROP TABLE IF EXISTS restaurant.test_perm CASCADE;

-- B5: TRUNCATE in strict Foreign Key dependency order
TRUNCATE TABLE restaurant.InventoryTransaction RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Payment RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.OrderItem RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.MenuItemIngredient RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Reservation RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Orders RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.MenuItem RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Ingredient RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Employee RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.RestaurantTable RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.MenuCategory RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.UnitOfMeasure RESTART IDENTITY CASCADE;
TRUNCATE TABLE restaurant.Role RESTART IDENTITY CASCADE;

-- B6: Data population with realistic data & subqueries
INSERT INTO restaurant.Role (RoleName) VALUES
('Waiter'), ('Chef'), ('Manager'), ('Hostess'), ('Bartender');

INSERT INTO restaurant.UnitOfMeasure (UnitName) VALUES
('kg'), ('liter'), ('piece'), ('gram'), ('ml');

INSERT INTO restaurant.MenuCategory (CategoryName) VALUES
('Pizza'), ('Drinks'), ('Burgers'), ('Pasta'), ('Salads');

INSERT INTO restaurant.Customer (FirstName, LastName, Phone, Email) VALUES
('Ali', 'Askarov', '+77011112233', 'ali.a@example.kz'),
('Dana', 'Baizhanova', '+77022223344', 'dana.b@example.kz'),
('Arman', 'Ilyasov', '+77055556677', 'arman.i@example.kz'),
('Zarina', 'Kalykova', '+77077778899', 'zarina.k@example.kz'),
('Serik', 'Akhmetov', '+77088889900', 'serik.a@example.kz');

INSERT INTO restaurant.Employee (FirstName, LastName, RoleID, Phone, HireDate, Salary, Gender) VALUES
('Anel', 'Dolatovna', (SELECT RoleID FROM restaurant.Role WHERE RoleName = 'Waiter'), '+77033334455', '2026-02-01', 250000.00, 'Female'),
('Anna', 'Kim', (SELECT RoleID FROM restaurant.Role WHERE RoleName = 'Chef'), '+77044445566', '2026-02-02', 450000.00, 'Female'),
('Murat', 'Sukhov', (SELECT RoleID FROM restaurant.Role WHERE RoleName = 'Manager'), '+77051112222', '2026-01-15', 600000.00, 'Male'),
('Elena', 'Petrova', (SELECT RoleID FROM restaurant.Role WHERE RoleName = 'Hostess'), '+77063332211', '2026-03-01', 220000.00, 'Female'),
('Diyar', 'Omanov', (SELECT RoleID FROM restaurant.Role WHERE RoleName = 'Bartender'), '+77074441122', '2026-02-20', 280000.00, 'Male');

INSERT INTO restaurant.RestaurantTable (TableNumber, Capacity, Location) VALUES
(1, 4, 'Window Side'),
(2, 2, 'Main Hall Center'),
(3, 6, 'VIP Terrace'),
(4, 2, 'Bar Counter'),
(5, 8, 'Private Dining Room');

INSERT INTO restaurant.MenuItem (CategoryID, ItemName, Price) VALUES
((SELECT CategoryID FROM restaurant.MenuCategory WHERE CategoryName = 'Pizza'), 'Pepperoni Pizza', 3200.00),
((SELECT CategoryID FROM restaurant.MenuCategory WHERE CategoryName = 'Drinks'), 'Craft Cola', 700.00),
((SELECT CategoryID FROM restaurant.MenuCategory WHERE CategoryName = 'Burgers'), 'BBQ Beef Burger', 2800.00),
((SELECT CategoryID FROM restaurant.MenuCategory WHERE CategoryName = 'Pasta'), 'Fettuccine Alfredo', 3400.00),
((SELECT CategoryID FROM restaurant.MenuCategory WHERE CategoryName = 'Salads'), 'Caesar Salad', 2400.00);

INSERT INTO restaurant.Ingredient (IngredientName, UnitID, CurrentStockQty, ReorderLevel) VALUES
('Flour', (SELECT UnitID FROM restaurant.UnitOfMeasure WHERE UnitName = 'kg'), 120.000, 20.000),
('Mozzarella Cheese', (SELECT UnitID FROM restaurant.UnitOfMeasure WHERE UnitName = 'kg'), 45.500, 10.000),
('Beef Patty', (SELECT UnitID FROM restaurant.UnitOfMeasure WHERE UnitName = 'piece'), 80.000, 15.000),
('Chicken Breast', (SELECT UnitID FROM restaurant.UnitOfMeasure WHERE UnitName = 'kg'), 30.000, 8.000),
('Romaine Lettuce', (SELECT UnitID FROM restaurant.UnitOfMeasure WHERE UnitName = 'kg'), 15.000, 5.000);

INSERT INTO restaurant.MenuItemIngredient (MenuItemID, IngredientID, QuantityRequired) VALUES
((SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Pepperoni Pizza'), (SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Flour'), 0.250),
((SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Pepperoni Pizza'), (SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Mozzarella Cheese'), 0.200),
((SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'BBQ Beef Burger'), (SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Beef Patty'), 1.000),
((SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Fettuccine Alfredo'), (SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Chicken Breast'), 0.150),
((SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Caesar Salad'), (SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Romaine Lettuce'), 0.100);

INSERT INTO restaurant.Orders (CustomerID, EmployeeID, OrderDate, Status, TableID) VALUES
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'ali.a@example.kz'), (SELECT EmployeeID FROM restaurant.Employee WHERE FirstName = 'Anel'), '2026-05-20 12:30:00', 'Completed', (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 1)),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'dana.b@example.kz'), (SELECT EmployeeID FROM restaurant.Employee WHERE FirstName = 'Anel'), '2026-05-21 14:15:00', 'Completed', (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 2)),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'arman.i@example.kz'), (SELECT EmployeeID FROM restaurant.Employee WHERE FirstName = 'Diyar'), '2026-05-22 19:00:00', 'Completed', (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 4)),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'zarina.k@example.kz'), (SELECT EmployeeID FROM restaurant.Employee WHERE FirstName = 'Anel'), '2026-05-23 18:00:00', 'Open', (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 3)),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'serik.a@example.kz'), (SELECT EmployeeID FROM restaurant.Employee WHERE FirstName = 'Anel'), '2026-05-23 19:30:00', 'Cancelled', (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 5));

INSERT INTO restaurant.OrderItem (OrderID, MenuItemID, Quantity, UnitPrice) VALUES
(1, (SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Pepperoni Pizza'), 2, 3200.00),
(1, (SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Craft Cola'), 2, 700.00),
(2, (SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'BBQ Beef Burger'), 1, 2800.00),
(3, (SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Fettuccine Alfredo'), 2, 3400.00),
(4, (SELECT MenuItemID FROM restaurant.MenuItem WHERE ItemName = 'Caesar Salad'), 1, 2400.00);

INSERT INTO restaurant.Payment (OrderID, Amount, PaymentMethod) VALUES
(1, 7800.00, 'Card'),
(2, 2800.00, 'Cash'),
(3, 6800.00, 'Mobile QR'),
(4, 2400.00, 'Card'),
(5, 4500.00, 'Card');

INSERT INTO restaurant.InventoryTransaction (IngredientID, QuantityChange, TransactionType) VALUES
((SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Flour'), 50.000, 'Restock'),
((SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Mozzarella Cheese'), -0.400, 'Usage'),
((SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Beef Patty'), -1.000, 'Usage'),
((SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Chicken Breast'), -0.300, 'Usage'),
((SELECT IngredientID FROM restaurant.Ingredient WHERE IngredientName = 'Romaine Lettuce'), -0.100, 'Usage');

INSERT INTO restaurant.Reservation (CustomerID, TableID, ReservationDate, Status) VALUES
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'ali.a@example.kz'), (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 1), '2026-05-25 18:00:00', 'Confirmed'),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'dana.b@example.kz'), (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 2), '2026-05-26 19:30:00', 'Pending'),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'arman.i@example.kz'), (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 3), '2026-05-27 20:00:00', 'Confirmed'),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'zarina.k@example.kz'), (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 4), '2026-05-28 13:00:00', 'Cancelled'),
((SELECT CustomerID FROM restaurant.Customer WHERE Email = 'serik.a@example.kz'), (SELECT TableID FROM restaurant.RestaurantTable WHERE TableNumber = 5), '2026-05-29 21:00:00', 'Confirmed');


-- C7: Two UPDATE statements with Business reasons and SELECT previews

-- Business reason: Increased pizza price by 10% due to rising ingredient costs.
SELECT count(*) FROM restaurant.MenuItem 
WHERE ItemName = 'Pepperoni Pizza';
-- 1 row will be affected

UPDATE restaurant.MenuItem
SET Price = Price * 1.10
WHERE ItemName = 'Pepperoni Pizza';


-- Business reason: Customer requested phone number correction.
SELECT count(*) 
FROM restaurant.Customer 
WHERE Email = 'ali.a@example.kz';
-- 1 row will be affected

UPDATE restaurant.Customer
SET Phone = '+77019998877'
WHERE Email = 'ali.a@example.kz';


-- C8: UPDATE ... FROM with join and SELECT preview

-- Business reason: Annual performance-based salary increase for all waiting staff.
SELECT count(*) 
FROM restaurant.Employee e
JOIN restaurant.Role r ON e.RoleID = r.RoleID
WHERE r.RoleName = 'Waiter';
-- 1 row will be affected

UPDATE restaurant.Employee emp
SET Salary = emp.Salary * 1.15
FROM restaurant.Role rol
WHERE emp.RoleID = rol.RoleID
  AND rol.RoleName = 'Waiter';


-- D9 & D10: DELETE within transaction, row count verification, and Business reason

-- Business reason: Removing cancelled reservations to clean up obsolete data.
SELECT count(*) FROM restaurant.Reservation WHERE Status = 'Cancelled';
-- 1 row for preview

BEGIN;
DELETE FROM restaurant.Reservation WHERE Status = 'Cancelled';
SELECT count(*) FROM restaurant.Reservation WHERE Status = 'Cancelled';
-- 0 rows
ROLLBACK;
