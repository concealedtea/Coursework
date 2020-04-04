INSERT INTO Tickets(theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
    VALUES('111','1','2009-06-23','12:00:00','1','8.50');

INSERT INTO TICKETS(theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
    VALUES('111','1','2009-06-23','11:00:00','50000','8.50');

INSERT INTO TICKETS(theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
    VALUES('111','4','2009-06-23','11:00:00','1','8.50');

UPDATE TICKETS SET ticketPrice = 10 WHERE customerID = '1';
UPDATE TICKETS SET ticketPrice = -1 WHERE customerID = '1';

UPDATE CUSTOMERS SET joinDate = '11-28-2016' WHERE customerID = '1';
UPDATE CUSTOMERS SET joinDate = '11-25-2015' WHERE customerID = '1';

UPDATE SHOWINGS SET movieID = 101, priceCode = 'B' WHERE theaterID = '111';
UPDATE SHOWINGS SET movieID = NULL, priceCode = 'C' WHERE theaterID = '111';