BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	ALTER TABLE Tickets
		ADD FOREIGN KEY (theaterID, showingDate, startTime)
		REFERENCES Showings(theaterID, showingDate, startTime);

    ALTER TABLE Tickets
        ADD FOREIGN KEY (customerID)
        REFERENCES Customers(customerID)
        ON DELETE SET NULL;
    
    ALTER TABLE Tickets
        ADD FOREIGN KEY (theaterID,seatNum)
        REFERENCES TheaterSeats(theaterID,seatNum)
        ON DELETE CASCADE;
COMMIT;