DROP FUNCTION IF EXISTS reduceSomeTicketPricesFunction;
CREATE FUNCTION reduceSomeTicketPricesFunction(
	IN maxTicketCount INTEGER
)
RETURNS INTEGER AS $totalTicketReductions$

DECLARE
	totalReductions INTEGER := 0;
	numReductions INTEGER := 0;
	keyID INTEGER;
    keyDate DATE;
    keyTime TIME;
	code CHAR(1);
	priceChange INTEGER;
DECLARE
	ticketCursor CURSOR FOR
		SELECT Tickets.theaterID, Tickets.showingDate, Tickets.startTime
		FROM Tickets LEFT JOIN Showings ON Tickets.theaterID = Showings.theaterID AND Tickets.showingDate = Showings.showingDate AND Tickets.startTime = Showings.startTime
        ORDER BY Showings.priceCode ASC, customerID ASC
		LIMIT maxTicketCount;
BEGIN

	OPEN ticketCursor;
		LOOP
			FETCH ticketCursor INTO keyID, keyDate, keyTime;
			EXIT WHEN NOT FOUND;

			SELECT priceCode INTO code FROM Showings WHERE theaterID = keyID AND showingDate = keyDate AND startTime = keyTime;

			CASE code
				WHEN 'A' THEN
					priceChange = 3.0;
                    totalReductions := totalReductions + 3;
				WHEN 'B' THEN
					priceChange = 2.0;
                    totalReductions := totalReductions + 2;
				WHEN 'C' THEN
					priceChange = 1.0;
                    totalReductions := totalReductions + 1;
                ELSE
                    priceChange = 0.0;
                    totalReductions := totalReductions;
			END CASE;
			
			UPDATE Tickets SET ticketPrice = ticketPrice - priceChange WHERE theaterID = keyID AND showingDate = keyDate AND startTime = keyTime;
		END LOOP;
	
	CLOSE ticketCursor;
	
	RETURN totalReductions;
	
END;
$totalTicketReductions$ LANGUAGE plpgsql;