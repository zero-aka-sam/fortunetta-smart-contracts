# CLI-01 Standards

1. `InitializeClient(args) => { return boolean || Error Message }`

    - Usage specification : Shall be used to upgrade the user from pseudo-level(level 0 : in node ) to real level initialization in the chain.

    - Accomplisments

    -   - Validate that the client is new, and doesn't exist previously in the reccords.
    -   - Define a Struct Client( address, level )
    -   - Return Boolean

2. `retrieveMyLevel(address) => { return levelId }`

    // Usage specification : Shall be used to retrieve level informations, pre every transaction and compared with retrieveEligibility(levelId) method and upgradeLevel() method is triggered if eligibility criteria is about to be met post the transaction

3. `retrieveEligibility(levelId) => { return Struct Eligibility }`

    // Usage specification : Shall be used to retrieve eligibility criteria of a specific level id provided as an argument

    //Structure
    {
    minBets : Int,
    minWins : Int,
    }

4. `retrieveMyBets(address) => { return Array[Struct Bet] }`

    // Usage specification : Shall be used to retrieve all the up-to-date betting informations for a specific client

5. `retrieveMyWins(address) => { return Array[Struct Wins] }`

    // Usage soecification : Shall be used to retrieve all the up-to-date winning informations for a specific client
