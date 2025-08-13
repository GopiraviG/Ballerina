import ballerina/data.xmldata;
import ballerina/http;
import ballerina/io;
import ballerinax/activemq.driver as _;
import ballerinax/java.jms;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /mobile on httpDefaultListener {
    private final jms:MessageProducer orderProducer;

    function init() returns error? {
        jms:Connection connection = check new (
            initialContextFactory = "org.apache.activemq.jndi.ActiveMQInitialContextFactory",
            providerUrl = "tcp://localhost:61616"
        );
        jms:Session session = check connection->createSession();
        self.orderProducer = check session.createProducer();
    }

    resource function post queuePush(@http:Payload request jsonPayload) returns error|xml|json|http:InternalServerError {
        do {

            int amount = jsonPayload.Amount;
            string mobileNumber = jsonPayload.MobileNumber;
            string currencyCode = jsonPayload.CurrencyCode;
            string fspCode = jsonPayload.FspCode;
            string debitAccountId = jsonPayload.DebitAccountId;

            // Create InputRequest for validation using declared variables
            InputRequest validationRequest = {
                Amount: amount,
                MobileNumber: mobileNumber,
                CurrencyCode: currencyCode,
                FspCode: fspCode,
                DebitAccountId: debitAccountId
            };

            // Validate the current request using declared variables
            var validationResult = validateRequest(validationRequest);
            if (validationResult.isValid == false) {
                return validationResult.errorPayload;
            } else {
                // Process the request further if validation is successful
                json successPayload = {
                    "Status": "Success",
                    "Message": "Request validated successfully",
                    "Data": {
                        "Amount": amount,
                        "MobileNumber": mobileNumber,
                        "CurrencyCode": currencyCode,
                        "FspCode": fspCode,
                        "DebitAccountId": debitAccountId
                    }
                };
                xml xmlResult = check xmldata:fromJson(successPayload);
                ToQueue author = check xmldata:parseAsType(xmlResult);
                io:println("Parsed XML Data: ", author);
                if (author.Data.FspCode == "ECONET") {
                    jms:MapMessage message = {
                        content: author
                    };
                    check self.orderProducer->sendTo({'type: jms:QUEUE, name: "econetQueue"}, message);
                } else if (author.Data.FspCode == "LUMITEL") {
                    jms:MapMessage message = {
                        content: author
                    };
                    check self.orderProducer->sendTo({'type: jms:QUEUE, name: "lumitelQueue"}, message);
                }

                return xmlResult;
            }
        }

on fail error err {
            return error("unhandled error", err);
        }
    }

}
