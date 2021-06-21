// CONTRACTS

1. Native contract      : ERC-20 Standard
2. Client contract      : CLI-01 Standard
3. Controller contract  : CON-01 Standard

// STANDARDS

1. CLI-01 Standardizations
    
    1. InitializeClient(args) => { return boolean || Error Message }
    
    // Accomplisments
    
    1. Validate that the client is new, and doesn't exist previously in the reccords.
    2. Define a Struct Client()
    3. Return Boolean || Error message
    4. // ERROR MESSAGES
       1. 101 ( Validation Error )  : Please check the argument provided. The argument should match the Client Struct values.
       2. 102 ( Transaction Error ) : Please make sure you have the sufficient balance.
