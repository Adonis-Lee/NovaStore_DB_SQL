-- ====> PART 1: DATABASE SETUP <====
-- (I will create database in this part.)

-- Here is for switch to master system database
USE master;
GO

-- If the database already exist, I delete it for starting freshly
IF EXISTS(SELECT name
          FROM sys.databases
          WHERE name = 'NovaStoreDB')
    DROP DATABASE NovaStoreDB;


-- I am creating a new database that is named "NovaStoreDB" and select it
GO
CREATE DATABASE NovaStoreDB;
GO
USE NovaStoreDB;
GO


-- ====> PART 2: CREATİNG TABLE <====
-- (I will create requested tables and add necessary variables.)

-- I create table for product categories.
CREATE TABLE Categories(
    CategoryID INT PRIMARY KEY IDENTITY (1,1), -- It has unique ID and grows automatically.
    CategoryName VARCHAR(50) NOT NULL          -- Name of the categories.
);

-- This table is created for products available in store.
CREATE TABLE Products(
    ProductID INT PRIMARY KEY IDENTITY (1,1),
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),                                            -- Product prices with 2 decimal places.
    Stock INT DEFAULT 0,                                            -- Number of the items available.
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)    -- Link to categories table.
);

-- Here is customer information table.
CREATE TABLE Customers(
    CustomerID INT PRIMARY KEY IDENTITY (1,1),
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100),
    UNIQUE (Email)                              -- Each email must be unique.
);

-- This table is for general order information.
CREATE TABLE Orders(
    OrderID INT PRIMARY KEY IDENTITY (1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),   -- Link to the customers.
    OrderDate DATETIME DEFAULT GETDATE(),                          -- Date of order ( default to today)
    TotalAmount DECIMAL(10,2)                                      -- Total money for this order.
);

-- Lastly, creating table for specific items inside each order.
CREATE TABLE OrderDetails(
    DetailID INT PRIMARY KEY IDENTITY (1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),         -- Link to the orders.
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),   -- Link to the products.
    Quantity INT                                                -- How many items were bought.
);


-- ====> PART 3: INSERTİNG DATA (Examples) <====
-- These datas is creating by AI. It can be change.

-- Added category names here.
INSERT INTO Categories(CategoryName)
VALUES ('Electronics'), ('Clothings'), ('Books'),
       ('Cosmetics'), ('Home & Lifestyle');


-- Added product list with prices and stock levels here.
INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
('MacBook Air', 1200.00, 15, 1),
('iPhone 14', 999.99, 25, 1),
('Cotton T-Shirt', 19.99, 50, 2),
('Blue Jeans', 49.99, 40, 2),
('SQL for Beginners', 29.50, 100, 3),
('Science Fiction Novel', 15.00, 30, 3),
('Rose Perfume', 85.00, 20, 4),
('Red Lipstick', 25.00, 60, 4),
('Desk Lamp', 35.00, 15, 5),
('Coffee Mug', 12.50, 100, 5),
('Wireless Mouse', 25.99, 5, 1),    -- Stok bilerek 20'den az (Bölüm 3'teki soru için)
('Winter Jacket', 120.00, 10, 2);   -- Stok bilerek 20'den az (Bölüm 3'teki soru için)

-- Sample customers were added here.
INSERT INTO Customers (FullName, City, Email)
VALUES
('Ahmet Yilmaz', 'Istanbul', 'ahmet.yilmaz@email.com'),
('Ayse Demir', 'Ankara', 'ayse.demir@email.com'),
('Mehmet Kaya', 'Izmir', 'mehmet.kaya@email.com'),
('Fatma Celik', 'Bursa', 'fatma.celik@email.com'),
('Ali Yildiz', 'Antalya', 'ali.yildiz@email.com');


-- Added sample orders here. If there is no date entered, today's date entered automatically as default.
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
(1, '2023-10-01', 1200.00), -- 1. Sipariş: Ahmet
(2, '2023-10-05', 19.99),   -- 2. Sipariş: Ayse
(1, '2023-10-10', 44.50),   -- 3. Sipariş: Ahmet
(3, '2023-10-12', 999.99),  -- 4. Sipariş: Mehmet
(4, '2023-10-15', 85.00),   -- 5. Sipariş: Fatma
(5, '2023-10-20', 155.00),  -- 6. Sipariş: Ali
(2, '2023-10-22', 25.99),   -- 7. Sipariş: Ayse
(1, DEFAULT, 25.00);        -- 8. Sipariş: Ahmet (default to today)

-- 4. OrderDetails (Sipariş Detayları) Veri Girişi
INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
(1, 1, 1),   -- 1. Sipariş: 1 adet MacBook
(2, 3, 1),   -- 2. Sipariş: 1 adet T-Shirt
(3, 5, 1),   -- 3. Sipariş: 1 adet SQL Kitabı
(3, 6, 1),   -- 3. Sipariş: 1 adet Roman
(4, 2, 1),   -- 4. Sipariş: 1 adet iPhone
(5, 7, 1),   -- 5. Sipariş: 1 adet Parfüm
(6, 12, 1),  -- 6. Sipariş: 1 adet Kışlık Ceket
(6, 9, 1),   -- 6. Sipariş: 1 adet Masa Lambası
(7, 11, 1),  -- 7. Sipariş: 1 adet Mouse
(8, 8, 1);   -- 8. Sipariş: 1 adet Ruj


SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;

SELECT FullName, City, OrderDate, TotalAmount
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

SELECT FullName, ProductName, Price, CategoryName
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN OrderDetails ON Orders.OrderID = OrderDetails.OrderID
INNER JOIN Products ON OrderDetails.ProductID = Products.ProductID
INNER JOIN Categories ON Products.CategoryID = Categories.CategoryID
WHERE Customers.FullName = 'Ahmet Yilmaz';

SELECT CategoryName, COUNT(ProductID) AS ProductCount
FROM Categories
LEFT JOIN Products ON Categories.CategoryID = Products.CategoryID
GROUP BY CategoryName;

SELECT FullName, SUM(TotalAmount) AS TotalSpend
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
GROUP BY Customers.FullName
ORDER BY TotalSpend DESC;

SELECT OrderID, OrderDate, DATEDIFF(day, OrderDate, GETDATE()) AS DayPassed
FROM Orders;

GO
CREATE View vw_OrderSummary AS
    SELECT
        Fullname, OrderDate, ProductName, Quantity
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
INNER JOIN OrderDetails On Orders.OrderID = OrderDetails.OrderID
INNER JOIN Products ON OrderDetails.ProductID = Products.ProductID;
GO

BACKUP DATABASE NovaStoreDB
TO DISK = '/tmp/NovaStoreDB.bak'
