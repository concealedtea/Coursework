BEGIN TRANSACTION;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
    INSERT INTO Showings(theaterID, showingDate, startTime, movieID, priceCode)
    SELECT newShow.theaterID,newShow.showingDate,newShow.startTime,newShow.movieID,NULL
    FROM ModifyShowings newShow
    WHERE theaterID + showingDate + startTime NOT IN (
        SELECT theaterID + showingDate + startTime FROM Showings
    );

    UPDATE Showings s
    SET movieID = newShow.movieID
    FROM ModifyShowings newShow
    WHERE s.theaterID + s.showingDate + s.startTime =  newShow.theaterID + newShow.showingDate + newShow.startTime;
COMMIT;