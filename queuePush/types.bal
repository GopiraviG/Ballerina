type request record {
    int Amount;
    string MobileNumber;
    string CurrencyCode;
    string FspCode;
    string DebitAccountId;
};

type requestArray record {|
    int Amount;
    string MobileNumber;
    string CurrencyCode;
    string FspCode;
    string DebitAccountId;
|};

type InputRequest record {
    int Amount;
    string MobileNumber;
    string CurrencyCode;
    string FspCode;
    string DebitAccountId;
};

type InputValidationResult record {
    boolean isValid;
    json errorPayload?;
};

type Data record {|
    int Amount;
    string MobileNumber;
    string CurrencyCode;
    string FspCode;
    string DebitAccountId;
|};

type ToQueue record {|
    string Status;
    string Message;
    Data Data;
|};

type RequestData record {
    int Amount;
    int MobileNumber;
    string CurrencyCode;
    string FspCode;
    int DebitAccountId;
};
