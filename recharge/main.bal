import ballerina/http;
import ballerina/time;

listener http:Listener httpDefaultListener = new (8080);

// Initialize scheduler when module starts - runs every 5 seconds
function init() {
    // Start the scheduler in a separate worker to avoid blocking
    worker SchedulerWorker {
        executePeriodicFetch();
    }
}
service /recharge on httpDefaultListener {

    resource function post television(@http:Payload InputRequest request) returns Output|json|error {
        do {
            // Error handling is done using check and if error blocks
            string? accountNumber = request.CustomerAccountNumber;
            string? smartCardNumber = request.SmartCardNumber;
            string? mobileNumber = request.MobileNumber;
            int? amount = request.Amount;
            string? packageId = request.PackageId;
            string? packageDuration = request.PackageDuration;
            string? reference = request.Reference;
            string? currency = request.Currency;
            string? isPosted = request.IsPosted.toString();
            time:Utc currentUtc = time:utcNow();
            time:Civil currentTime = time:utcToCivil(currentUtc);
            int seconds = <int>(currentTime.second ?: 0);
            string timestamp = string `${currentTime.year}-${currentTime.month}-${currentTime.day}T${currentTime.hour}:${currentTime.minute}:${seconds}`;
            string description;

            // Generate unique message ID
            string messageId = generateMessageId();

            // Validate required fields with proper null handling
            if (accountNumber is () || accountNumber == "" || accountNumber == " ") {
                description = "CustomerAccountNumber is required and cannot be empty or null";
                return mandatory(description);
            }

            if (smartCardNumber is () || smartCardNumber == "" || smartCardNumber == " ") {
                description = "SmartCardNumber is required and cannot be empty or null";
                return mandatory(description);
            }

            if (mobileNumber is () || mobileNumber == "" || mobileNumber == " ") {
                description = "MobileNumber is required and cannot be empty or null";
                return mandatory(description);
            }

            if (packageId is () || packageId == "" || packageId == " ") {
                description = "PackageId is required and cannot be empty or null";
                return mandatory(description);
            }

            if (packageDuration is () || packageDuration == "" || packageDuration == " ") {
                description = "PackageDuration is required and cannot be empty or null";
                return mandatory(description);
            }

            if (reference is () || reference == "" || reference == " ") {
                description = "Reference is required and cannot be empty or null";
                return mandatory(description);
            }

            if (currency is () || currency == "" || currency == " ") {
                description = "Currency is required and cannot be empty or null";
                return mandatory(description);
            }

            if (amount is ()) {
                description = "Amount is required and cannot be empty or null";
                return mandatory(description);
            }

            if (isPosted is ()) {
                description = "IsPosted is required and cannot be empty or null";
                return mandatory(description);
            }

            string status;
            if (amount <= 0) {
                status = "failed";
            } else {
                status = "success";
            }
            // Call the sqlInsert function to insert the recharge record
            json|error insertResult = sqlInsert(messageId, accountNumber, smartCardNumber, mobileNumber, amount, packageId, packageDuration, reference, currency, isPosted, timestamp, status);
            return insertResult;
            
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }

    }
   
}