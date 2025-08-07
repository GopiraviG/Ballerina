import ballerina/io;
import ballerina/time;
import ballerina/sql;
import ballerina/lang.runtime;

// Flag to control scheduler execution
boolean schedulerRunning = false;

// Function to start the scheduler task
public function startSchedulerTask() {
    if (!schedulerRunning) {
        schedulerRunning = true;
        io:println("Scheduler task started successfully");
        error? initialFetch = fetchTelevisionRecords();
        if initialFetch is error {
            io:println("Initial fetch error: " + initialFetch.message());
        }
    } else {
        io:println("Scheduler task is already running");
    }
}

// Function to stop the scheduler task
public function stopSchedulerTask() {
    schedulerRunning = false;
    io:println("Scheduler task stopped");
}

// Function to execute scheduler task periodically every 5 seconds
public function executePeriodicFetch() {
    startSchedulerTask();
    
    while (schedulerRunning) {
        error? fetchResult = fetchTelevisionRecords();
        if fetchResult is error {
            io:println("SCHEDULER ERROR: " + fetchResult.message());
        }
        
        // Wait for 5 seconds before the next execution - using decimal as required by API
        decimal intervalSeconds = 30.0; 
        runtime:sleep(intervalSeconds);
        io:println("SCHEDULER TASK COMPLETED. Waiting 5 seconds for next execution...");
    }
    
    io:println("Scheduler execution loop ended");
}

// Function to fetch records from television table
function fetchTelevisionRecords() returns error? {
    time:Utc currentUtc = time:utcNow();
    time:Civil currentTime = time:utcToCivil(currentUtc);
    int seconds = <int>(currentTime.second ?: 0);
    string timestamp = string `${currentTime.year}-${currentTime.month}-${currentTime.day}T${currentTime.hour}:${currentTime.minute}:${seconds}`;
    
    io:println("SCHEDULER TASK STARTED: " + timestamp);
    io:println("Fetching records from television table...");
    
    // Query to fetch all records from television table
    sql:ParameterizedQuery selectQuery = `SELECT MessageId, AccountNumber, SmartCardNumber, MobileNumber, Amount, PackageId, PackageDuration, Reference, Currency, IsPosted, RechargeDate, Status FROM television ORDER BY RechargeDate DESC`;
    
    // Execute the query
    stream<TelevisionRecord, sql:Error?> recordStream = mysqlClient->query(selectQuery);
    
    int recordCount = 0;
    
    // Process each record from the stream
    error? streamResult = recordStream.forEach(function(TelevisionRecord televisionRecord) {
        recordCount += 1;
        
        // Process the fetched record
        processTelevisionRecord(televisionRecord);
        
        });
    
        
    if streamResult is error {
        io:println("FETCH ERROR: " + streamResult.message());
        return streamResult;
    }
    
    // Print summary
    io:println("FETCH COMPLETED:");
    io:println("Total Records: " + recordCount.toString());
    io:println("SCHEDULER TASK COMPLETED: " + timestamp);
    
    return;
}

// Function to process individual television record
function processTelevisionRecord(TelevisionRecord televisionRecord) {
    string messageId = televisionRecord.MessageId;
    string accountNumber = televisionRecord.AccountNumber;
    int amount = televisionRecord.Amount;
    string status = televisionRecord.Status;
    string smartCardNumber = televisionRecord.SmartCardNumber;
    string mobileNumber = televisionRecord.MobileNumber;
    string packageId = televisionRecord.PackageId;
    string packageDuration = televisionRecord.PackageDuration;
    string reference = televisionRecord.Reference;
    string currency = televisionRecord.Currency;
    string isPosted = televisionRecord.IsPosted.toString();
    
    // Log record details
    io:println("Processing Record - MessageId: " + messageId + 
               ", Account: " + accountNumber + 
               ", Amount: " + amount.toString() + 
               ", Status: " + status +
               ", SmartCard: " + smartCardNumber +
               ", Mobile: " + mobileNumber +
               ", PackageId: " + packageId +
               ", PackageDuration: " + packageDuration +
               ", Reference: " + reference +
               ", Currency: " + currency +
               ", IsPosted: " + isPosted.toString());
    
    
    // Example: Update processed timestamp for specific conditions
    if (status == "failed") {
        status= "success";
        amount=20;
        error? updateResult = updateRecordProcessedTime(messageId, smartCardNumber, status, amount);
        if updateResult is error {
            io:println("UPDATE ERROR for MessageId " + messageId + ": " + updateResult.message());
        }
    }
}

// Function to update status and amount a record
function updateRecordProcessedTime(string messageId, string smartCardNumber, string status, int amount) returns error? {
    
    sql:ParameterizedQuery updateQuery = `UPDATE television SET Status = ${status}, Amount=${amount} WHERE MessageId = ${messageId} and SmartCardNumber = ${smartCardNumber}`;
    
    sql:ExecutionResult|sql:Error updateResult = mysqlClient->execute(updateQuery);
    
    if updateResult is sql:Error {
        return updateResult;
    }
    
    sql:ExecutionResult execResult = updateResult;
    int? affectedRowCount = execResult.affectedRowCount;
    if affectedRowCount is int && affectedRowCount > 0 {
        io:println("Updated status and amount for MessageId: " + messageId);
    }
    
    return;
}
