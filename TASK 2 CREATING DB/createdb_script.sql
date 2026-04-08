-- DATABASE (optional)
-- CREATE DATABASE restaurant_db;
-- SCHEMA
CREATE SCHEMA IF NOT EXISTS restaurant;
SET search_path TO restaurant;

-- ROLE
CREATE TABLE IF NOT EXISTS Role (
    RoleID SERIAL PRIMARY KEY,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

-- UNIT
CREATE TABLE IF NOT EXISTS UnitOfMeasure (
    UnitID SERIAL PRIMARY KEY,
    UnitName VARCHAR(20) NOT NULL UNIQUE
);

-- CATEGORY
CREATE TABLE IF NOT EXISTS MenuCategory (
    CategoryID SERIAL PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

-- CUSTOMER
CREATE TABLE IF NOT EXISTS Customer (
    CustomerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE,
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- EMPLOYEE
CREATE TABLE IF NOT EXISTS Employee (
    EmployeeID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    RoleID INT,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    HireDate DATE CHECK (HireDate > DATE '2026-01-01'),
    Salary NUMERIC(10,2) CHECK (Salary >= 0),
    Gender VARCHAR(10) CHECK (Gender IN ('Male','Female')),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (RoleID) REFERENCES Role(RoleID)
);

-- TABLE
CREATE TABLE IF NOT EXISTS RestaurantTable (
    TableID SERIAL PRIMARY KEY,
    TableNumber INT UNIQUE NOT NULL,
    Capacity INT CHECK (Capacity > 0),
    Location VARCHAR(50),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- MENU ITEM
CREATE TABLE IF NOT EXISTS MenuItem (
    MenuItemID SERIAL PRIMARY KEY,
    CategoryID INT,
    ItemName VARCHAR(100) NOT NULL UNIQUE,
    Price NUMERIC(10,2) CHECK (Price > 0),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (CategoryID) REFERENCES MenuCategory(CategoryID)
);

-- INGREDIENT
CREATE TABLE IF NOT EXISTS Ingredient (
    IngredientID SERIAL PRIMARY KEY,
    IngredientName VARCHAR(100) NOT NULL UNIQUE,
    UnitID INT,
    CurrentStockQty NUMERIC(12,3) CHECK (CurrentStockQty >= 0),
    ReorderLevel NUMERIC(12,3) CHECK (ReorderLevel >= 0),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (UnitID) REFERENCES UnitOfMeasure(UnitID)
);

-- MENU ITEM INGREDIENT
CREATE TABLE IF NOT EXISTS MenuItemIngredient (
    MenuItemID INT NOT NULL,
    IngredientID INT NOT NULL,
    QuantityRequired NUMERIC(12,3) CHECK (QuantityRequired > 0),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (MenuItemID, IngredientID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

-- ORDERS
CREATE TABLE IF NOT EXISTS Orders (
    OrderID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT,
    OrderDate TIMESTAMP CHECK (OrderDate > TIMESTAMP '2026-01-01'),
    Status VARCHAR(20) DEFAULT 'Open',
    TableID INT,
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID)
);

-- ORDER ITEM
CREATE TABLE IF NOT EXISTS OrderItem (
    OrderID INT NOT NULL,
    MenuItemID INT NOT NULL,
    Quantity INT CHECK (Quantity > 0),
    UnitPrice NUMERIC(10,2) CHECK (UnitPrice > 0),
    Subtotal NUMERIC(12,2) GENERATED ALWAYS AS (Quantity * UnitPrice) STORED,
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (OrderID, MenuItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID)
);

-- PAYMENT
CREATE TABLE IF NOT EXISTS Payment (
    PaymentID SERIAL PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    Amount NUMERIC(12,2) CHECK (Amount > 0),
    PaymentMethod VARCHAR(20),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- INVENTORY
CREATE TABLE IF NOT EXISTS InventoryTransaction (
    TransactionID SERIAL PRIMARY KEY,
    IngredientID INT NOT NULL,
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    QuantityChange NUMERIC(12,3),
    TransactionType VARCHAR(20) CHECK (TransactionType IN ('Usage','Restock')),
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

-- RESERVATION
CREATE TABLE IF NOT EXISTS Reservation (
    ReservationID SERIAL PRIMARY KEY,
    CustomerID INT NOT NULL,
    TableID INT NOT NULL,
    ReservationDate TIMESTAMP CHECK (ReservationDate > TIMESTAMP '2026-01-01'),
    Status VARCHAR(20) DEFAULT 'Pending',
    record_ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID)
);

-- INSERT (rerunnable)

INSERT INTO Role (RoleName) VALUES
('Waiter'),('Chef'),('Manager')
ON CONFLICT DO NOTHING;

INSERT INTO UnitOfMeasure (UnitName) VALUES
('kg'),('liter')
ON CONFLICT DO NOTHING;

INSERT INTO MenuCategory (CategoryName) VALUES
('Pizza'),('Drinks')
ON CONFLICT DO NOTHING;

INSERT INTO Customer (FirstName,LastName,Phone) VALUES
('Ali','A','87011111111'),
('Dana','B','87022222222')
ON CONFLICT DO NOTHING;

INSERT INTO Employee (FirstName,LastName,RoleID,Phone,HireDate,Salary,Gender) VALUES
('Anel','Dolatovna',1,'87033333333','2026-02-01',200000,'Female'),
('Anna','Kim',2,'87044444444','2026-02-02',300000,'Female')
ON CONFLICT DO NOTHING;

INSERT INTO RestaurantTable (TableNumber,Capacity,Location) VALUES
(1,4,'Window'),
(2,2,'Center')
ON CONFLICT DO NOTHING;

INSERT INTO MenuItem (CategoryID,ItemName,Price) VALUES
(1,'Pepperoni',2500),
(2,'Cola',500)
ON CONFLICT DO NOTHING;

INSERT INTO Ingredient (IngredientName,UnitID,CurrentStockQty,ReorderLevel) VALUES
('Flour',1,50,10),
('Cheese',1,20,5)
ON CONFLICT DO NOTHING;

INSERT INTO MenuItemIngredient (MenuItemID,IngredientID,QuantityRequired) VALUES
(1,1,0.3),
(1,2,0.2)
ON CONFLICT DO NOTHING;

INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TableID) VALUES
(1,1,'2026-02-10',1),
(2,2,'2026-02-11',2)
ON CONFLICT DO NOTHING;

INSERT INTO OrderItem (OrderID,MenuItemID,Quantity,UnitPrice) VALUES
(1,1,2,2500),
(2,2,3,500)
ON CONFLICT DO NOTHING;

INSERT INTO Payment (OrderID,Amount,PaymentMethod) VALUES
(1,5000,'Cash'),
(2,1500,'Card')
ON CONFLICT DO NOTHING;

INSERT INTO InventoryTransaction (IngredientID,QuantityChange,TransactionType) VALUES
(1,-2,'Usage'),
(2,-1,'Usage')
ON CONFLICT DO NOTHING;

INSERT INTO Reservation (CustomerID,TableID,ReservationDate,Status) VALUES
(1,1,'2026-04-01 18:00:00','Pending'),
(2,2,'2026-04-02 19:00:00','Confirmed')
ON CONFLICT DO NOTHING;