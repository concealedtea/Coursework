import java.sql.*;
import java.io.*;
import java.util.*;

/**
 * A class that connects to PostgreSQL and disconnects.
 * You will need to change your credentials below, to match the usename and password of your account
 * in the PostgreSQL server.
 * The name of your database in the server is the same as your username.
 * You are asked to include code that tests the methods of the MovieTheaterApplication class
 * in a similar manner to the sample RunFilmsApplication.java program.
*/


public class RunMovieTheaterApplication
{
    public static void main(String[] args) {
    	
    	Connection connection = null;
    	try {
    	    //Register the driver
    		Class.forName("org.postgresql.Driver"); 
    	    // Make the connection.
            // You will need to fill in your real username (twice) and password for your
			// Postgres account in the arguments of the getConnection method below.
			String SQLusername = "jzfan";
			String SQLpassword = "aeiou091298Jf?";
            connection = DriverManager.getConnection(
                                                     "jdbc:postgresql://cse180-db.lt.ucsc.edu/" + SQLusername,
                                                     SQLusername,
                                                     SQLpassword);
            
            if (connection != null)
                System.out.println("Connected to the database!");

            /* Include your code below to test the methods of the MovieTheaterApplication class.
             * The sample code in RunFilmsApplication.java should be useful.
             * That code tests other methods for a different database schema.
             * Your code below: */
			MovieTheaterApplication app = new MovieTheaterApplication(connection);
			
			// Test getShowingsCount for B
			System.out.println("Testing getShowingsCount....");
			Integer numOfAs = app.getShowingsCount("B");
			System.out.println("Total number of Showings with priceCode of B is: " + numOfAs + "\n");

			// Test updateMovieName for Avatar (101) replacing w/ Avatar 1
			System.out.println("Testing updateMovieName....");
			Integer oldMovieID = 101;
			String newMovieName = "Avatar 1";
			Integer numOfReplacements = app.updateMovieName(oldMovieID, newMovieName);
			System.out.println("Total number of changes (101) to Movies Table was: " + numOfReplacements + "\n");

			// Test updateMovieName for 888 replacing w/ Star Wars: A New Hope
			System.out.println("Testing updateMovieName....");
			Integer oldMovieID2 = 888;
			String newMovieName2 = "Star Wars: A New Hope";
			Integer numOfReplacements2 = app.updateMovieName(oldMovieID2, newMovieName2);
			System.out.println("Total number of changes (888) to Movies Table was: " + numOfReplacements2 + "\n");

			// Ticket Reduction Tests
			System.out.println("Testing reduceSomeTicketPrices");
			Integer numTicketsUpdated = app.reduceSomeTicketPrices(15);
			System.out.println("Total price reduced (15) is: " + numTicketsUpdated);

			System.out.println("Testing reduceSomeTicketPrices");
			Integer numTicketsUpdated2 = app.reduceSomeTicketPrices(99);
			System.out.println("Total price reduced (99) is: " + numTicketsUpdated2);
            
            /*******************
            * Your code ends here */
            
    	}
    	catch (SQLException | ClassNotFoundException e) {
    		System.out.println("Error while connecting to database: " + e);
    		e.printStackTrace();
    	}
    	finally {
    		if (connection != null) {
    			// Closing Connection
    			try {
					connection.close();
				} catch (SQLException e) {
					System.out.println("Failed to close connection: " + e);
					e.printStackTrace();
				}
    		}
    	}
    }
}
