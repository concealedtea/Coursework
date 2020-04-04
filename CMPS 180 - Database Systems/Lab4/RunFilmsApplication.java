import java.sql.*;
import java.io.*;
import java.util.*;

/**
 * A sample class that connects to PostgreSQL and runs methods of the FilmsApplication class.
 * However, you are not being given the FilmsApplication class.
 */
public class RunFilmsApplication
{
    public static void main(String[] args) throws ClassNotFoundException,
        FileNotFoundException, IOException, SQLException {
    
    Connection connection;
    Class.forName("org.postgresql.Driver");  //Registering the driver

    connection = DriverManager.getConnection(
            "jdbc:postgresql://cmps180-db.lt.ucsc.edu/database",
            "username", "password");  //Making the Connection 

    FilmsApplication app = new FilmsApplication(connection);

    double maxHours = 1.5;
    List<String> titles = app.getFilmTitlesNoLongerThan(maxHours);
    for (String title : titles)
        System.out.println(title);
    
    String firstName = "John";
    String lastName = "Farnsworth";
    String email = "john.farnsworth@customer.org";
    String address = "41 El Alto Parkway";
    String district = "Maharashtra";
    String postalCode = "56883";
    String phone = "51917807050";
    app.addCustomer(firstName, lastName, email, address, district, postalCode, phone);

    connection.close(); //Closing Connection
    }
}
