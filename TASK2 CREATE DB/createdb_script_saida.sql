-- 1. DATABASE
DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db;
USE restaurant_db;

-- 2. Customer
CREATE TABLE Customer (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE,
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Employee
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(10,2) NOT NULL CHECK (Salary > 0),
    IsActive BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. RestaurantTable
CREATE TABLE RestaurantTable (
    TableID INT AUTO_INCREMENT PRIMARY KEY,
    TableNumber INT NOT NULL,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Location VARCHAR(50)
);

-- 5. Reservation
CREATE TABLE Reservation (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    TableID INT NOT NULL,
    ReservationDate DATETIME NOT NULL CHECK (ReservationDate > '2026-01-01'),
    GuestCount INT NOT NULL CHECK (GuestCount > 0),
    Status VARCHAR(20) NOT NULL DEFAULT 'Booked',
    CreatedAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID)
);

-- 6. MenuCategory
CREATE TABLE MenuCategory (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

-- 7. MenuItem
CREATE TABLE MenuItem (
    MenuItemID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryID INT NOT NULL,
    ItemName VARCHAR(100) NOT NULL,
    Description VARCHAR(255),
    Price DECIMAL(10,2) NOT NULL CHECK (Price > 0),
    IsAvailable BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (CategoryID) REFERENCES MenuCategory(CategoryID)
);

-- 8. Ingredient
CREATE TABLE Ingredient (
    IngredientID INT AUTO_INCREMENT PRIMARY KEY,
    IngredientName VARCHAR(100) NOT NULL UNIQUE,
    UnitOfMeasure VARCHAR(20) NOT NULL,
    CurrentStockQty DECIMAL(10,2) NOT NULL CHECK (CurrentStockQty >= 0),
    ReorderLevel DECIMAL(10,2) NOT NULL CHECK (ReorderLevel >= 0)
);

-- 9. MenuItemIngredient
CREATE TABLE MenuItemIngredient (
    MenuItemID INT,
    IngredientID INT,
    QuantityRequired DECIMAL(10,2) NOT NULL CHECK (QuantityRequired > 0),
    PRIMARY KEY (MenuItemID, IngredientID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

-- 10. Orders
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT,
    TableID INT,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status VARCHAR(20) NOT NULL DEFAULT 'Open',
    TotalAmount DECIMAL(10,2) DEFAULT 0 CHECK (TotalAmount >= 0),
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID)
);

-- 11. OrderItem
CREATE TABLE OrderItem (
    OrderID INT,
    MenuItemID INT,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL CHECK (UnitPrice > 0),
    Subtotal DECIMAL(10,2) GENERATED ALWAYS AS (Quantity * UnitPrice) STORED,
    PRIMARY KEY (OrderID, MenuItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID)
);

-- 12. Payment
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
    PaymentMethod VARCHAR(20) NOT NULL,
    Status VARCHAR(20) NOT NULL DEFAULT 'Completed',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- 13. InventoryTransaction
CREATE TABLE InventoryTransaction (
    TransactionID INT AUTO_INCREMENT PRIMARY KEY,
    IngredientID INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    QuantityChange DECIMAL(10,2) NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    ReferenceOrderID INT,
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID)
);

-- 14. ADD record_ts колонка
ALTER TABLE Customer ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE Employee ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE RestaurantTable ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE Reservation ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE MenuCategory ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE MenuItem ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE Ingredient ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE MenuItemIngredient ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE Orders ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE OrderItem ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE Payment ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);
ALTER TABLE InventoryTransaction ADD record_ts DATE NOT NULL DEFAULT (CURRENT_DATE);

-- Customer
INSERT INTO Customer (FirstName, LastName, Phone, Email) VALUES
('Aidos', 'K', '87011111111', 'aidos@mail.com'),
('Dana', 'S', '87022222222', 'dana@mail.com');

-- Employee
INSERT INTO Employee (FirstName, LastName, Role, Phone, HireDate, Salary) VALUES
('Ali', 'M', 'Waiter', '87033333333', '2026-02-01', 200000),
('Sara', 'T', 'Manager', '87044444444', '2026-02-05', 400000);

-- RestaurantTable
INSERT INTO RestaurantTable (TableNumber, Capacity, Location) VALUES
(1, 4, 'Indoor'),
(2, 6, 'VIP');

-- MenuCategory
INSERT INTO MenuCategory (CategoryName, Description) VALUES
('Drinks', 'Beverages'),
('Food', 'Main dishes');

-- MenuItem
INSERT INTO MenuItem (CategoryID, ItemName, Price) VALUES
(1, 'Cola', 500),
(2, 'Pizza', 2500);

-- Ingredient
INSERT INTO Ingredient (IngredientName, UnitOfMeasure, CurrentStockQty, ReorderLevel) VALUES
('Flour', 'kg', 50, 10),
('Cheese', 'kg', 20, 5);

-- MenuItemIngredient 
INSERT INTO MenuItemIngredient (MenuItemID, IngredientID, QuantityRequired) VALUES
(2, 1, 0.3),
(2, 2, 0.2);

-- Orders
INSERT INTO Orders (CustomerID, EmployeeID, TableID) VALUES
(1, 1, 1),
(2, 2, 2);

-- OrderItem
INSERT INTO OrderItem (OrderID, MenuItemID, Quantity, UnitPrice) VALUES
(1, 2, 1, 2500),
(2, 1, 2, 500);

-- Payment
INSERT INTO Payment (OrderID, Amount, PaymentMethod) VALUES
(1, 2500, 'Cash'),
(2, 1000, 'Card');

-- Reservation
INSERT INTO Reservation (CustomerID, TableID, ReservationDate, GuestCount) VALUES
(1, 1, '2026-02-10', 2),
(2, 2, '2026-03-01', 4);

-- InventoryTransaction
INSERT INTO InventoryTransaction (IngredientID, QuantityChange, TransactionType) VALUES
(1, -5, 'Usage'),
(2, -2, 'Usage');