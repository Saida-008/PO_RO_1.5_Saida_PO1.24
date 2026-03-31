DROP DATABASE IF EXISTS restaurant_db;
CREATE DATABASE restaurant_db;
USE restaurant_db;

CREATE TABLE Role (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE UnitOfMeasure (
    UnitID INT PRIMARY KEY AUTO_INCREMENT,
    UnitName VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE MenuCategory (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE,
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Employee (
    EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    RoleID INT,
    Phone VARCHAR(20) UNIQUE NOT NULL,
    HireDate DATE CHECK (HireDate > '2026-01-01'),
    Salary DECIMAL(10,2) CHECK (Salary >= 0),
    Gender VARCHAR(10) CHECK (Gender IN ('Male','Female')),
    FOREIGN KEY (RoleID) REFERENCES Role(RoleID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE RestaurantTable (
    TableID INT PRIMARY KEY AUTO_INCREMENT,
    TableNumber INT UNIQUE NOT NULL,
    Capacity INT CHECK (Capacity > 0),
    Location VARCHAR(50),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE MenuItem (
    MenuItemID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryID INT,
    ItemName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price > 0),
    FOREIGN KEY (CategoryID) REFERENCES MenuCategory(CategoryID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Ingredient (
    IngredientID INT PRIMARY KEY AUTO_INCREMENT,
    IngredientName VARCHAR(100) NOT NULL UNIQUE,
    UnitID INT,
    CurrentStockQty DECIMAL(12,3) CHECK (CurrentStockQty >= 0),
    ReorderLevel DECIMAL(12,3) CHECK (ReorderLevel >= 0),
    FOREIGN KEY (UnitID) REFERENCES UnitOfMeasure(UnitID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE MenuItemIngredient (
    MenuItemID INT,
    IngredientID INT,
    QuantityRequired DECIMAL(12,3) CHECK (QuantityRequired > 0),
    PRIMARY KEY (MenuItemID, IngredientID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID),
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATETIME CHECK (OrderDate > '2026-01-01'),
    Status VARCHAR(20) DEFAULT 'Open',
    TableID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE OrderItem (
    OrderID INT,
    MenuItemID INT,
    Quantity INT CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) CHECK (UnitPrice > 0),
    Subtotal DECIMAL(12,2) GENERATED ALWAYS AS (Quantity * UnitPrice) STORED,
    PRIMARY KEY (OrderID, MenuItemID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (MenuItemID) REFERENCES MenuItem(MenuItemID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    OrderID INT,
    PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Amount DECIMAL(12,2) CHECK (Amount > 0),
    PaymentMethod VARCHAR(20),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE InventoryTransaction (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    IngredientID INT,
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    QuantityChange DECIMAL(12,3),
    TransactionType VARCHAR(20),
    FOREIGN KEY (IngredientID) REFERENCES Ingredient(IngredientID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Reservation (
    ReservationID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT NOT NULL,
    TableID INT NOT NULL,
    ReservationDate DATETIME CHECK (ReservationDate > '2026-01-01'),
    Status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (TableID) REFERENCES RestaurantTable(TableID),
    record_ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Role (RoleName) VALUES ('Waiter'),('Chef'),('Manager');
INSERT INTO UnitOfMeasure (UnitName) VALUES ('kg'),('liter');
INSERT INTO MenuCategory (CategoryName) VALUES ('Pizza'),('Drinks');

INSERT INTO Customer (FirstName,LastName,Phone) VALUES
('Ali','A','87011111111'),
('Dana','B','87022222222');

INSERT INTO Employee (FirstName,LastName,RoleID,Phone,HireDate,Salary,Gender) VALUES
('Anel','Dolatovna',1,'87033333333','2026-02-01',200000,'Female'),
('Anna','Kim',2,'87044444444','2026-02-02',300000,'Female');

INSERT INTO RestaurantTable (TableNumber,Capacity,Location) VALUES
(1,4,'Window'),(2,2,'Center');

INSERT INTO MenuItem (CategoryID,ItemName,Price) VALUES
(1,'Pepperoni',2500),
(2,'Cola',500);

INSERT INTO Ingredient (IngredientName,UnitID,CurrentStockQty,ReorderLevel) VALUES
('Flour',1,50,10),
('Cheese',1,20,5);

INSERT INTO MenuItemIngredient (MenuItemID,IngredientID,QuantityRequired) VALUES
(1,1,0.3),(1,2,0.2);

INSERT INTO Orders (CustomerID,EmployeeID,OrderDate,TableID) VALUES
(1,1,'2026-02-10',1),
(2,2,'2026-02-11',2);

INSERT INTO OrderItem (OrderID,MenuItemID,Quantity,UnitPrice) VALUES
(1,1,2,2500),
(2,2,3,500);

INSERT INTO Payment (OrderID,Amount,PaymentMethod) VALUES
(1,5000,'Cash'),
(2,1500,'Card');

INSERT INTO InventoryTransaction (IngredientID,QuantityChange,TransactionType) VALUES
(1,-2,'Usage'),
(2,-1,'Usage');

INSERT INTO Reservation (CustomerID,TableID,ReservationDate,Status) VALUES
(1,1,'2026-04-01 18:00:00','Pending'),
(2,2,'2026-04-02 19:00:00','Confirmed');