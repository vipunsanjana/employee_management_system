import ballerina/sql;
import ballerina/http;
import ballerinax/mysql;


listener http:Listener employeeListener = new (8081);


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
// Define the Employee record
type Employee record {|
    int id?;
    string name;
    string position;
    string department;
    string email;
    decimal salary;
|};
service /employee on employeeListener {

    resource function post createEmployee(http:Caller caller, http:Request req) returns error? {
        // Parse the request payload using a custom method
        Employee employeeDetails = parseEmployeePayload(req);
        
        sql:ParameterizedQuery query = `INSERT INTO employees (name, position, department, email, salary) 
                                         VALUES (${employeeDetails.name}, ${employeeDetails.position}, 
                                                 ${employeeDetails.department}, ${employeeDetails.email}, 
                                                 ${employeeDetails.salary})`;
        // Execute the query and ignore the result
        _ = check dbClient->execute(query);

        // Respond with success message
        check caller->respond({"success": "Employee created successfully"});
    }

    resource function get getEmployee(http:Caller caller, http:Request req, string id) returns error? {
        sql:ParameterizedQuery query = `SELECT * FROM employees WHERE id = ${id}`;
        stream<Employee, sql:Error> resultStream = <stream<Employee, sql:Error>>dbClient->query(query, Employee);
        var result = resultStream.next();

        if (result is record {| Employee value; |}) {
            json response = result.value.toJson();
            check caller->respond(response);
        } else {
            check caller->respond({"error": "Unable to fetch employee"});
        }
    }

    resource function put updateEmployee(http:Caller caller, http:Request req, string id) returns error? {
        // Parse the request payload using a custom method
        Employee employeeDetails = parseEmployeePayload(req);
        
        sql:ParameterizedQuery query = `UPDATE employees SET name = ${employeeDetails.name}, 
                                         position = ${employeeDetails.position}, 
                                         department = ${employeeDetails.department}, 
                                         email = ${employeeDetails.email}, 
                                         salary = ${employeeDetails.salary} 
                                         WHERE id = ${id}`;
        // Execute the query and ignore the result
        _ = check dbClient->execute(query);

        // Respond with success message
        check caller->respond({"success": "Employee updated successfully"});
    }

    resource function delete deleteEmployee(http:Caller caller, http:Request req, string id) returns error? {
        sql:ParameterizedQuery query = `DELETE FROM employees WHERE id = ${id}`;
        // Execute the query and ignore the result
        _ = check dbClient->execute(query);

        // Respond with success message
        check caller->respond({"success": "Employee deleted successfully"});
    }

    // Custom function to parse the request payload and map it to Employee record
    function parseEmployeePayload(http:Request req) returns Employee|error {
        // Read the payload as JSON and convert it to Employee record type
        json jsonPayload = check req.getJsonPayload(); // Adjusted to use only for payload reading
        Employee employeeDetails = check jsonPayload.cloneWithType(Employee);
        return employeeDetails;
    }
}

function parseEmployeePayload(http:Request o) returns Employee {
    return {name: "", position: "", department: "", email: "", salary: 0};
}
