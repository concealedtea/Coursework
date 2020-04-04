DROP SCHEMA Lab1 CASCADE;
CREATE SCHEMA Lab1;
ALTER ROLE jzfan SET SEARCH_PATH to Lab1;

CREATE TABLE Movies (
    movieID INT PRIMARY KEY,
    name VARCHAR(30),
    year INT,
    rating CHAR(1),
    length INT,
    totalEarned numeric(7,2)
);

CREATE TABLE Theaters (
    theaterID INT PRIMARY KEY,
    address VARCHAR(40),
    numSeats INT
);

CREATE TABLE TheaterSeats (
    theaterID INT,
    seatNum INT,
    brokenSeat BOOLEAN,
    FOREIGN KEY (theaterID) REFERENCES Theaters,
    PRIMARY KEY (theaterID, seatNum)
);

CREATE TABLE Showings (
    theaterID INT,
    showingDate DATE,
    startTime TIME,
    movieID INT,
    priceCode CHAR(1),
    FOREIGN KEY (theaterID) REFERENCES Theaters,
    FOREIGN KEY (movieID) REFERENCES Movies,
    PRIMARY KEY (theaterID, showingDate, startTime)
);

CREATE TABLE Customers (
    customerID INT PRIMARY KEY,
    name VARCHAR(30),
    address VARCHAR(40),
    joinDate DATE,
    status CHAR(1)
);

CREATE TABLE Tickets (
    theaterID INT,
    seatNum INT,
    showingDate DATE,
    startTime TIME,
    customerID INT,
    ticketPrice numeric(4,2),
    PRIMARY KEY (theaterID, seatNum, showingDate, startTime),
    FOREIGN KEY (customerID) REFERENCES Customers(customerID),
    FOREIGN KEY (theaterID, showingDate, startTime) REFERENCES Showings(theaterID,showingDate,startTime),
    FOREIGN KEY (theaterID, seatNum) REFERENCES TheaterSeats(theaterID, seatNum)
);
