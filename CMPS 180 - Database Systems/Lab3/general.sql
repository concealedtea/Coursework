BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
	ALTER TABLE Tickets ADD CONSTRAINT positive_tickePrice CHECK (ticketPrice > 0);
    ALTER TABLE Customers ADD CONSTRAINT old_join CHECK (joinDate > '11-27-2015');
    ALTER TABLE Showings ADD CONSTRAINT not_null_names CHECK ((movieID IS NOT NULL AND priceCode IS NOT NULL) OR (movieID IS NULL AND priceCode IS NULL));
COMMIT;