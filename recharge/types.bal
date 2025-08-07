type InputRequest record {|
    string CustomerAccountNumber?;
    string SmartCardNumber?;
    string MobileNumber?;
    int Amount?;
    string PackageId?;
    string PackageDuration?;
    string Reference?;
    string Currency?;
    boolean IsPosted?;
|};

type SystemDateTimeResponse record {|
    int timestamp;
    decimal fractionalSeconds;
    boolean hasSystemZone;
|};

type Output record {|
    string MessageId;
    string AccountNumber;
    string SmartCardNumber;
    string Status;
    string MobileNumber;
    int Amount;
    string PackageId;
    string PackageDuration;
    string Reference;
    string Currency;
    boolean IsPosted;
    string RechargeDate;
|};

type Mandotory record {|
    string Status;
    string Message;
    string Description;
|};

type TelevisionRecord record {|
    string MessageId;
    string AccountNumber;
    string SmartCardNumber;
    string MobileNumber;
    int Amount;
    string PackageId;
    string PackageDuration;
    string Reference;
    string Currency;
    string IsPosted;
    string RechargeDate;
    string Status;
|};