SELECT
    rating
    , SUM(misreported) as misreportCount
FROM (
    SELECT 
        Movies.movieID
        , rating
        , CASE
            WHEN totalEarned = earningsView.allTickets THEN 0
            ELSE 1 END as misreported
    FROM Movies
    JOIN earningsView ON
    Movies.movieID = earningsView.movieID) msc
GROUP BY rating
;

/*  Results after resetting
rating | misreportcount
--------+----------------
 R      |              3
 P      |              1
 G      |              2
(3 rows) */

DELETE FROM TICKETS
WHERE theaterID = 111 AND seatNum = 1 AND showingDate = '2009-06-23' AND startTime = '11:00:00';

DELETE FROM TICKETS
WHERE theaterID = 444 AND seatNum = 5 AND showingDate = '2020-06-24' AND startTime = '15:00:00';

SELECT
    rating
    , SUM(misreported) as misreportCount
FROM (
    SELECT 
        Movies.movieID
        , rating
        , CASE
            WHEN totalEarned = earningsView.allTickets THEN 0
            ELSE 1 END as misreported
    FROM Movies
    JOIN earningsView ON
    Movies.movieID = earningsView.movieID) msc
GROUP BY rating
;

/* After Delete Statements
 rating | misreportcount
--------+----------------
 R      |              3
 P      |              2
 G      |              2
(3 rows) */