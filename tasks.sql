USE little_lemon_db;

-- Task 1: Create a virtable table called OrderView thatcreate a virtual table called OrdersView that focuses on OrderID, Quantity and Cost columns within the Orders table for all orders with a quantity greater than 2
CREATE VIEW OrdersView AS (
	SELECT OrderID, Quantity, TotalCost
    FROM Orders
    WHERE Quantity > 2
);

SELECT * FROM OrdersView;

-- Task 2: Extract information on all customers with orders that cost more than $150
SELECT 
	c.CustomerID, c.FullName,
    o.OrderID, o.TotalCost,
    m.MenuName,
    mi.CourseName, mi.StarterName
FROM
	Customers c JOIN Orders o ON c.CustomerID = o.CustomerID
    JOIN Menus m ON o.MenuID = m.MenuID
    JOIN MenuItems mi ON m.MenuItemID = mi.MenuItemID
WHERE o.TotalCost > 150
ORDER BY o.TotalCost ASC;
    
    
-- Task 3: List all menu items for which more than 2 orders have been placed
SELECT MenuName 
FROM Menus 
WHERE MenuID = ANY
	(SELECT MenuID
    FROM Orders
    WHERE Quantity > 2);
    
    
-- Task 4: Create a procedure that displays the maximum ordered quantity in the Orders table

CREATE PROCEDURE GetMaxQuantity()
SELECT MAX(Quantity) AS "Max Quantity in Order" FROM ORDERS;



-- Task 5: Create a prepared statement called GetOrderDetail which accept the CustomerID and return the orderID, quantity and the order cost.
PREPARE GetOrderDetail FROM 'SELECT OrderID, Quantity, TotalCost FROM Orders WHERE CustomerID = ?';

set @id = 1;
Execute GetOrderDetail USING @id;



-- Task 6: Create a stored procedure called CancelOrder for deleteing an order record based on the user input of the order id.
DELIMITER //
CREATE PROCEDURE CancelOrder(IN inputOrderID INT)
BEGIN
	DELETE FROM Orders WHERE OrderID = inputOrderID;
END //



-- Task 7: Add records to the booking table
INSERT INTO bookings (BookingID, BookingDate, TableNumber, CustomerID)
VALUES 
(1, '2022-10-10', 5, 1),
(2, '2022-11-12', 3, 3),
(3, '2022-10-11', 2, 2),
(4, '2022-10-13', 2, 1);

SELECT * FROM Bookings;



-- Task 8: Create a stored procedure called CheckBooking to check whether a table in the restaurant is already booked
DELIMITER //

CREATE PROCEDURE CheckBooking(
IN in_BookingDate DATE, 
IN in_TableNumber INT
)
BEGIN
	DECLARE booking_status INT;
    
    SELECT COUNT(*) INTO booking_status 
    FROM Bookings
    WHERE BookingDate = in_BookingDate AND TableNumber = in_TableNumber;
    
    IF booking_status > 0 THEN
		SELECT CONCAT("Table ", in_TableNumber,  " is already booked") AS "Booking status";
	ELSE
		SELECT CONCAT("Table ", in_TableNumber,  " is available") AS "Booking status";
	END IF;
END //
    DELIMITER ;
    
    

-- TASK 9: Create a procedure called AddValidBooking to add and verify bookings or decline any reservations for tables that are already booked under another name
DELIMITER //
CREATE PROCEDURE AddValidBooking(
	IN in_BookingDate DATE,
    IN in_TableNumber INT,
    IN in_CustomerID INT
    )
BEGIN
	DECLARE v_isbooked INT;
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO v_isbooked
    FROM Bookings
	WHERE BookingDate = in_BookingDate
		AND TableNumber = in_TableNumber;

    -- If the table is already booked, rollback
    IF v_isbooked > 0 THEN
		ROLLBACK;
		SELECT CONCAT("Table ", in_TableNumber, " is already booked on ", in_BookingDate, "- booking cancelled") AS BookingStatus;
	
    -- IF the table is available, insert the new bookings and commit the transaction
	ELSE
		INSERT INTO Bookings (BookingDate, TableNumber, CustomerID)
        VALUES (in_BookingDate, in_TableNumber, in_CustomerID);
	
    COMMIT;
		SELECT CONCAT("Booking successful for Table ", in_TableNumber, " on ", in_BookingDate) AS BookingStatus;
	END IF;
END //
    
DELIMITER ;



-- Task 10: Create a procedure called AddBooking to add a new table booking record

DELIMITER //

CREATE PROCEDURE AddBooking(
IN in_BookingID INT,
IN in_CustomerID INT,
IN in_BookingDate DATE,
IN in_TableNumber INT
)
BEGIN
	-- insert a new booking into the Bookings table
  	INSERT INTO Bookings (BookingID, CustomerID, BookingDate, TableNumber)
  	VALUES (in_BookingID, in_CustomerID, in_BookingDate, in_TableNumber);

	-- Output message
	SELECT "New booking added" AS Confirmation;
END //

DELIMITER ;



-- Task 11: Create a new procedure called UpdateBooking that is used to update existing bookings in the booking table

DELIMITER //

CREATE PROCEDURE UpdateBooking(
IN in_BookingID INT,
IN in_newBookingDate DATE)

BEGIN
	-- Update the booking date for the given booking ID
	UPDATE Bookings
    SET BookingDate = in_NewBookingDate
    WHERE BookingID = in_BookingID;
    
    -- Output message
    SELECT CONCAT("Booking ", in_BookingID, " updated ") AS Confirmation;
    
    END //
    
    DELIMITER ;



-- Task 12: Create a procedure called CancelBooking to cancel or remove a booking
DELIMITER //

CREATE PROCEDURE CancelBooking(
IN in_BookingID INT)
BEGIN
	-- Delete booking with the specified booking ID
	DELETE FROM Bookings WHERE BookingID = in_BookingID;
    
    -- Output message
    SELECT CONCAT("Booking ", in_BookingID, " deleted ") AS Confirmation;
END //

DELIMITER ;
