SELECT 
    DISTINCT Movies.name
    , Movies.year
FROM (
    SELECT 
        movieID
    FROM Showings
    JOIN (
        SELECT 
            theaterID
            , showingDate
            , startTime
        FROM TICKETS
        JOIN (
            SELECT
                customerID
            FROM Customers 
            WHERE name = 'Donald Duck'
        ) as customerSub
        on tickets.customerID = customerSub.customerID
    ) as ticketSub
    on Showings.theaterID = ticketSub.theaterID 
    and Showings.showingDate = ticketSub.showingDate
    and Showings.startTime = ticketSub.startTime
) as showingsSub 
JOIN Movies 
on Movies.movieID = showingsSub.movieID
;