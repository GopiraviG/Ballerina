import ballerina/lang.regexp;

function inputValidation(string description) returns json {
    json errorPayload = {
        "Status": "Failure",
        "Message": "Input validation failed",
        "Description": description
    };
    return errorPayload;
}


public function validateRequest(InputRequest request) returns  json {
    string description = "";
    
    // Validate mobile number (10 digits)
    do {
        regexp:RegExp mobileRegex = check regexp:fromString("^[0-9]{10}$");
        if !mobileRegex.isFullMatch(request.MobileNumber) {
            description = "Invalid mobile number format. It should be 10 digits.";
            return {isValid: false, errorPayload: inputValidation(description)};
        }
    } on fail {
        json errorPayload = {
            "Status": "Failure",
            "Message": "Validation error",
            "Description": "Mobile number validation failed"
        };
        return {isValid: false, errorPayload: errorPayload};
    }
    
    // Validate currency code (3 uppercase letters)
    do {
        regexp:RegExp currencyRegex = check regexp:fromString("^[A-Z]{3}$");
        if (!currencyRegex.isFullMatch(request.CurrencyCode)) {
            description = "Invalid currency code format. It should be 3 uppercase letters.";
            return {isValid: false, errorPayload: inputValidation(description)};
        }
    } on fail {
        json errorPayload = {
            "Status": "Failure",
            "Message": "Validation error",
            "Description": "Currency code validation failed"
        };
        return {isValid: false, errorPayload: errorPayload};
    }
    
    // Validate FSP code (ECONET or LUMITEL)
    do {
        regexp:RegExp fspRegex = check regexp:fromString("^(ECONET|LUMITEL)$");
        if (!fspRegex.isFullMatch(request.FspCode)) {
            description = "Invalid FSP code. It should be either 'ECONET' or 'LUMITEL'.";
            return {isValid: false, errorPayload: inputValidation(description)};
        }
    } on fail {
        json errorPayload = {
            "Status": "Failure",
            "Message": "Validation error",
            "Description": "FSP code validation failed"
        };
        return {isValid: false, errorPayload: errorPayload};
    }
    
    // Validate debit account ID (13 digits)
    do {
        regexp:RegExp debitAccountRegex = check regexp:fromString("^[0-9]{13}$");
        if (!debitAccountRegex.isFullMatch(request.DebitAccountId)) {
            description = "Invalid Debit Account ID format. It should be 13 digits.";
            return {isValid: false, errorPayload: inputValidation(description)};
        }
    } on fail {
        json errorPayload = {
            "Status": "Failure",
            "Message": "Validation error",
            "Description": "Debit Account ID validation failed"
        };
        return {isValid: false, errorPayload: errorPayload};
    }
    
    // Validate amount (positive integer)
    if request.Amount <= 0 {
        description = "Invalid amount. It should be a positive number.";
        return {isValid: false, errorPayload: inputValidation(description)};
    }
}