DROP TABLE IF EXISTS tempShowings;
DROP TABLE IF EXISTS tempCustomers;
DROP TABLE IF EXISTS joinedones;
DROP TABLE IF EXISTS finalTemp;

SELECT
    Showings.theaterID
    , showingDate
    , priceCode
INTO TEMP TABLE tempShowings
FROM Showings
JOIN (
    SELECT 
        theaterID 
    FROM Theaters WHERE numSeats > 5
) as bigTheaters on Showings.theaterID = bigTheaters.theaterID
WHERE showingDate between '2019-06-01' and '2019-06-30'
AND priceCode IS NOT NULL;

SELECT 
    Tickets.customerID
    , theaterID
    , showingDate
    , address
INTO TEMP TABLE tempCustomers
FROM Tickets
JOIN (
    SELECT
        customerID
        , address
    FROM Customers WHERE name like 'D%'
) as customerD on customerD.customerID = Tickets.customerID;

SELECT 
    Customers.customerID
    , Customers.address as custAddress
    , Customers.name
    , Theaters.theaterID
    , Theaters.address
    , Theaters.numSeats
    , showingDate
INTO TEMP TABLE joinedones
FROM Theaters
JOIN tempCustomers on Theaters.theaterID = tempCustomers.theaterID
JOIN Customers on Customers.customerID = tempCustomers.customerID;

SELECT
    joinedOnes.customerID as custID
    , joinedOnes.name as custName
    , joinedOnes.custAddress as custAddress
    , joinedOnes.address as theaterAddress
    , Theaters.numSeats as theaterSeats
    , priceCode as priceCode
INTO TEMP TABLE finalTemp
FROM joinedones
JOIN tempShowings on joinedOnes.theaterID = tempShowings.theaterID
    and joinedOnes.showingDate = tempShowings.showingDate
JOIN Theaters on joinedOnes.theaterID = Theaters.theaterID;

SELECT 
    DISTINCT * 
FROM finalTemp;