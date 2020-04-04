SELECT
    distinct Theaters.theaterID
    , address
FROM (
    SELECT 
        theaterID
    FROM TheaterSeats
    WHERE brokenSeat = True
) as theaterSeatsSub
JOIN Theaters on theaterSeatsSub.theaterID = Theaters.theaterID;
