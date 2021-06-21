// CONTRACTS

1. Native contract      : ERC-20 Standard
2. Client contract      : CLI-01 Standard
3. Controller contract  : CON-01 Standard

// STANDARDS

1. CLI-01 Standardizations
    
    1. InitializeClient(args) => { return boolean || Error Message }
    
    // Usage specification : Shall be used to upgrade the user from pseudo-level(level 0 : in node ) to real level initialization in the chain. 
    
    // Accomplisments
    
    1. Validate that the client is new, and doesn't exist previously in the reccords.
    2. Define a Struct Client( address, level )
    3. Return Boolean

    2. retrieveClient(address) => { return Struct Client }

    // Usage specification : Shall be used to retrieve level informations, pre every transaction and compared with retrieveEligibility(levelId) method and upgradeLevel() method     is triggered if eligibility criteria is about to be met post the transaction
    
    3. retrieveEligibility(levelId) => { return Struct Eligibility }
    
    // Usage specification : Shall be used to retrieve eligibility criteria of a specific level id provided as an argument
