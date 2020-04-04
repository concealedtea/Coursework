DROP VIEW IF EXISTS earningsView;

CREATE VIEW earningsView AS 
    SELECT 
        movieID
        , SUM(allTickets) as allTickets
    FROM (
        (SELECT 
            movieID 
            , 0 as allTickets
        FROM MOVIES)
        UNION
        (SELECT 
                Showings.movieID as movieID
                , CASE 
                    WHEN SUM(ticketPrice) > 0 THEN SUM(ticketPrice)
                    ELSE 0 END as allTickets
            FROM TICKETS RIGHT JOIN SHOWINGS ON 
            (tickets.theaterID = showings.theaterID AND tickets.showingDate = showings.showingDate and tickets.startTime = showings.startTime)
            WHERE movieID IS NOT NULL
            GROUP BY Showings.movieID)
    ) tics
    GROUP BY movieID
    ORDER BY SUM(allTickets) DESC
    ;
