import ballerina/io;
import ballerina/test;

// Before Suite Function

@test:BeforeSuite
function beforeSuiteFunc() {
    io:println("I'm the before suite function!");
}

// Test function
@test:Config {}function hello(string name) returns string {
    if (name == "") {
        return "Hello, World!";
    }
    return "Hello, " + name;
}


// Negative Test function

@test:Config {}
function negativeTestFunction() {
    string welcomeMsg = hello("jjj");
    test:assertEquals(welcomeMsg, "Hello, World!");
}

// After Suite Function

@test:AfterSuite
function afterSuiteFunc() {
    io:println("I'm the after suite function!");
}
