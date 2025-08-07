import ballerina/sql;
import ballerina/time;
import ballerina/io;

function mandatory(string description) returns json {
    json errorPayload = {
        "Status": "Failure",
	    "Message": "Mandatory parameter missing",
	    "Description": description
    };
    return errorPayload;
}

function generateMessageId() returns string {
    // Get current UTC time
    time:Utc currentUtc = time:utcNow();
    int timestamp = currentUtc[0];
    decimal fractionalSeconds = currentUtc[1];
    
    // Convert fractional seconds to string and extract digits
    string fractionalStr = fractionalSeconds.toString();
    string fractionalPart = fractionalStr.substring(2, 8); // Get 6 digits after decimal
    
    // Create message ID with timestamp and fractional seconds
    string messageId = string `MSG${timestamp}${fractionalPart}`;
    
    // Convert to uppercase for consistency
    string finalMessageId = messageId.toUpperAscii();
    
    return finalMessageId;
}

function sqlInsert(string messageId, string accountNumber, string smartCardNumber, string mobileNumber, int amount, string packageId, string packageDuration, string reference, string currency, string isPosted, string timestamp, string status) returns json|error {
    // Insert the recharge record into the database with message ID
    sql:ParameterizedQuery insertQuery = `INSERT INTO television (MessageId, AccountNumber, SmartCardNumber, MobileNumber, Amount, PackageId, PackageDuration, Reference, Currency, IsPosted, RechargeDate, Status) 
                                          VALUES (${messageId}, ${accountNumber}, ${smartCardNumber}, ${mobileNumber}, ${amount}, ${packageId}, ${packageDuration}, ${reference}, ${currency}, ${isPosted}, ${timestamp},${status})`;
                
    // Step 2: Execute the insert operation
    sql:ExecutionResult|sql:Error insertResult = mysqlClient->execute(insertQuery);
    
    // Print status code and result message
    if insertResult is sql:Error {
        io:println("INSERT STATUS: ERROR");
        io:println("ERROR CODE: DB_INSERT_ERROR");
        io:println("ERROR MESSAGE: " + insertResult.message());
        io:println("RESULT MESSAGE: Database insertion failed");
        
        json errorResponse = {
            message: "Database insertion failed",
            code: "DB_INSERT_ERROR",
            details: insertResult.message()
        };
        return errorResponse;
    }

    // Step 3: Check if insertion was successful
    sql:ExecutionResult execResult = insertResult;
    int? affectedRows = execResult.affectedRowCount;
    (string|int)? lastInsertId = execResult.lastInsertId;
    
    // Print successful execution details
    io:println("INSERT STATUS: SUCCESS");
    io:println("STATUS CODE: INSERT_SUCCESS");
    
    if affectedRows is int {
        io:println("AFFECTED ROWS: " + affectedRows.toString());
    } else {
        io:println("AFFECTED ROWS: Not available");
    }
    
    if lastInsertId is string {
        io:println("LAST INSERT ID: " + lastInsertId);
    } else if lastInsertId is int {
        io:println("LAST INSERT ID: " + lastInsertId.toString());
    } else {
        io:println("LAST INSERT ID: Not available");
    }
    
    io:println("RESULT MESSAGE: Record inserted successfully");
    
    if affectedRows is () || affectedRows <= 0 {
        io:println("INSERT STATUS: FAILED");
        io:println("STATUS CODE: INSERT_FAILED");
        io:println("RESULT MESSAGE: No rows were inserted");
        
        json errorResponse = {
            message: "No rows were inserted",
            code: "INSERT_FAILED"
        };
        return errorResponse;
    }
    
    // Return success response
    json successResponse = {
        Status: "INSERT_SUCCESS",
        MessageId: messageId,
        Description: "Record inserted successfully",
        Reference: reference
    };
    return successResponse;
}