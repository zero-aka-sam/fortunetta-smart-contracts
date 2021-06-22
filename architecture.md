# CONTRACTS

1. Native contract : ERC-20 Standard
2. Client contract : CLI-01 Standard
3. Controller contract : CON-01 Standard

## CLI-01 STANDARDS

1.  `initiateRound()`

_starts the round, with new block timer_

1.  `betOnOne()`

_places bet on option one_

2.  `betOnTwo()`

_places bet on option two_

3.  `betOnThree()`

_places bet on option three_

4.  `retrieveDailyRewards() `

_retrieves the reward information set with allocateDailyRewards() method_

> **OUTPUT SAMPLE**

```

[
{
day : 1,
amount : 500
},
{
day : 2,
amount : 400
}
]

```

4.  `receiveDailyReward( day : Int, address : address )`

_distributes allocated amount, received as response invoking retrieveDailyRewards() _

> **VALIDATIONS**

-   The method privately calls, validateDailyRewardsElibility(), and distributes reward only if eligibility is true.

5.  `validateDailyRewardsEligibility(day : Int, address : address)`

_validates if, eligible for the respective daily reward_

> **OUTPUT SAMPLE**

`true || false`

6.  `validateUnlockLevelEligibility(currentLevel : Int, address : address)`

_validates if, eligible for the next level to be unlocked_

**OUTPUT SAMPLE**

`true || false`

6.  `unlockLevel([{currentLevel : Int, address : address })`

_unlocks the next level and awards respective badges_

## CON-01 STANDARDS

1.  `initiateRound()`

_starts the round, with new block timer_

2.  `declareOneAsWon()`

_declares option one as won, and distributes the winning funds_

3.  `declareTwoAsWon()`

_declares option two as won, and distributes the winning funds_

4.  `declareTwoAsWon()`

_declares option three as won, and distributes the winning funds_

5.  `allocateDailyRewardsAndEligibility([{day : Int, level : Int, reward : Int, minBets : Int, minSpend : Int, minAge : Int ]},...)`

_allocates reward amounts and eligibilities to receive respective daily rewards_

> **NOTE**

-   Min age is the timeframe spent after the first bet.

6. `allocateLevelsAndEligibility([{level : Int, title : String, minBets : Int, minSpend : Int, minAge : Int ]})`

_allocates eligibilities to receive respective level batches_

> **NOTE**

-   Min age is the timeframe spent after the first bet.
