import ballerina/http;

public function main() returns error? {
    // Initialize the employee service listener
    listener http:Listener employeeListener = new (8081);
    employeeService employeeServiceInstance = new ();
    check employeeListener.attach(employeeServiceInstance);

    // Initialize the admin service listener
    listener http:Listener adminListener = new (8082);
    check new adminService(adminListener);
    
    // Add additional startup configurations if needed
}
