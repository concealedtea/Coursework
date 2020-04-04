SELECT
    Customers.customerID
    , name
FROM (
    SELECT DISTINCT
        customerID
        , (showingDate, startTime) as combinedTuple
    FROM Tickets
    GROUP BY customerID, combinedTuple
    HAVING count(customerID) > 2
) as ticketSub
JOIN Customers on Customers.customerID = ticketSub.customerID
WHERE name like '%a%' or name like '%A%'