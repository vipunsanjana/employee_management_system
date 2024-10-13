import ballerina/sql;
import ballerina/http;
import ballerinax/mysql;


listener http:Listener adminListener = new (8082);

// Define the DatabaseConfig record
type DatabaseConfig record {
    string host;
    int port;
    string username;
    string password;
    string database;
};

// Load the database configuration from Ballerina.toml
configurable DatabaseConfig databaseConfig = ?;

// Create a new MySQL client using the configuration
final mysql:Client dbClient = check new (databaseConfig.host, databaseConfig.username, databaseConfig.password, databaseConfig.database, databaseConfig.port);
// Define the Admin record
type Admin record {|
    int id?;
    string username;
    string password;
    string email;
|};

service /admin on adminListener {

   // Create Admin
resource function post createAdmin(http:Caller caller, http:Request req) returns error? {
    // Parse the request payload using a custom method
    Admin adminDetails = parseAdminPayload(req);
    
    sql:ParameterizedQuery query = `INSERT INTO admins (username, password, email) 
                                     VALUES (${adminDetails.username}, ${adminDetails.password}, 
                                             ${adminDetails.email})`;
    // Execute the query and ignore the result
    _ = check dbClient->execute(query);

    // Respond with success message
    check caller->respond({"success": "Admin created successfully"});
}


    // Get Admin by ID
    resource function get getAdmin(http:Caller caller, http:Request req, string id) returns error? {
        sql:ParameterizedQuery query = `SELECT * FROM admins WHERE id = ${id}`;
        stream<Admin, sql:Error> resultStream = <stream<Admin, sql:Error>>dbClient->query(query, Admin);
        var result = resultStream.next();

        if (result is record {| Admin value; |}) {
            json response = result.value.toJson();
            check caller->respond(response);
        } else {
            check caller->respond({"error": "Unable to fetch admin"});
        }
    }

 // Update Admin
resource function put updateAdmin(http:Caller caller, http:Request req, string id) returns error? {
    // Parse the request payload using a custom method
    Admin adminDetails = parseAdminPayload(req);

    sql:ParameterizedQuery query = `UPDATE admins SET username = ${adminDetails.username}, 
                                     password = ${adminDetails.password}, 
                                     email = ${adminDetails.email} 
                                     WHERE id = ${id}`;
    // Execute the query and ignore the result
    _ = check dbClient->execute(query);

    // Respond with success message
    check caller->respond({"success": "Admin updated successfully"});
}

    // Delete Admin
    resource function delete deleteAdmin(http:Caller caller, http:Request req, string id) returns error? {
        sql:ParameterizedQuery query = `DELETE FROM admins WHERE id = ${id}`;
        var result = dbClient->execute(query);

        if (result is error) {
            check caller->respond({"error": "Unable to delete admin"});
        } else {
            check caller->respond({"success": "Admin deleted successfully"});
        }
    }
}

function parseAdminPayload(http:Request o) returns Admin {
    return {username: "", password: "", email: ""};
}
