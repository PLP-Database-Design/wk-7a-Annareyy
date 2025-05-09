--What was achived in the code below
--Normalize to 1NF whereby it splits multivalued Products into single rows
--Normalize to 2NF by separating CustomerName from product details to eliminate partial dependency.
  -- Creating the original ProductDetail table
CREATE TABLE ProductDetail (
  OrderID INT,
  CustomerName VARCHAR(100),
  Products VARCHAR(255)
);

-- Inserting data
INSERT INTO ProductDetail VALUES
(101, 'John Doe', 'Laptop, Mouse'),
(102, 'Jane Smith', 'Tablet, Keyboard, Mouse'),
(103, 'Emily Clark', 'Phone');

-- Create a helper table with numbers (for splitting)
CREATE TEMPORARY TABLE numbers (n INT);
INSERT INTO numbers (n) VALUES (1), (2), (3), (4), (5);

-- Create a new table with 1NF structure: one product per row
CREATE TABLE OrderDetails_1NF AS
SELECT 
  pd.OrderID,
  pd.CustomerName,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(pd.Products, ',', numbers.n), ',', -1)) AS Product
FROM ProductDetail pd
JOIN numbers ON CHAR_LENGTH(pd.Products) - CHAR_LENGTH(REPLACE(pd.Products, ',', '')) >= numbers.n - 1
ORDER BY pd.OrderID;

-- Adding quantity information.
ALTER TABLE OrderDetails_1NF ADD Quantity INT;

UPDATE OrderDetails_1NF SET Quantity = 
  CASE 
    WHEN Product = 'Laptop' THEN 2
    WHEN Product = 'Mouse' AND OrderID = 101 THEN 1
    WHEN Product = 'Tablet' THEN 3
    WHEN Product = 'Keyboard' THEN 1
    WHEN Product = 'Mouse' AND OrderID = 102 THEN 2
    WHEN Product = 'Phone' THEN 1
    ELSE 1
  END;

-- Create Orders table (for 2NF)
CREATE TABLE Orders AS
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails_1NF;

-- Create OrderItems table (fully normalized 2NF)
CREATE TABLE OrderItems AS
SELECT OrderID, Product, Quantity
FROM OrderDetails_1NF;
