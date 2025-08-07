import ballerina/http;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /mobile on httpDefaultListener {
    resource function post queuePush(@http:Payload InputRequest request) returns error|json|http:InternalServerError {
        do {
            int amount = request.Amount;
            string mobileNumber = request.MobileNumber;
            string currencyCode = request.CurrencyCode;
            string fspCode = request.FspCode;
            string DebitAccountId = request.DebitAccountId;

        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}
