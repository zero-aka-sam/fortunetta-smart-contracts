// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;


import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IController.sol";
import "./interfaces/IClient.sol";
import "./interfaces/IBSCV.sol";
import "./interfaces/IBANK.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";

contract Client is IClient,Ownable{
    /* ========== States ========== */
    //ERC-20
    IBSCV public BSCV;

    //BANK
    IBANK public Bank;

    //Controller
    IController public Controller;

    //Array of Rounds
    round[] internal rounds;

    //Array of Users
    User[] internal users;

    //Countdown for the rounds
    uint32 public Countdown;

    //track userId through address
    mapping(address => uint32)private userId;
    
    //track address through userId 
    mapping(uint32 => address)private userAddress;

    //validation
    mapping(address => mapping(uint256 => uint256))private betAmounts;

    //tax 
    uint256 public Tax = uint256(10);

    //restTime after each bet
    uint256 public restTime;
    
    /* ========== Structs ========== */

    //struct containing all info for a round
    struct round{
        uint256 roundId;
        uint32 start;
        uint32 end;
        address[] bettingAddressesOnOne;
        uint256[] bettingAmountsOnOne;
        address[] bettingAddressesOnTwo;
        uint256[] bettingAmountsOnTwo;
        address[] bettingAddressesOnThree;
        uint256[] bettingAmountsOnThree;
        uint256 winningChoice;
        uint256 totalPrize;
    }
    
    //struct containing all info for each user
    struct User{
        uint32 UserID;
        uint32 Level;
        uint256 PendingRewards;
        uint256 CollectedRewards;
        uint256 LockTill;
        uint256 BetCounts;
        bool Approved;
    }

    /* ========== Events ========== */

    event betPlaced(uint32 userID,uint256 choice,uint256 _amount);
    event roundCreated(uint256 roundId);
    
    /* ========== Constructor ========== */

    constructor(IBSCV _token,IController _controller,uint32 _countdown,uint256 _restTime,IBANK _bank){
        BSCV = _token;
        Controller = _controller;
        Countdown = _countdown;
        restTime = _restTime;
        Bank = _bank;
    }

    /* ========== Public Functions ========== */

    /** * @dev used to bet in the current round
    The user is registered if he/she is a new user and assigned a new userId
    */ 
    function bet(uint256 _choice,uint256 _amount)public returns(uint32 _userID,uint256 amount,string memory result){
        //should enter 1 or 2 or 3 to bet in a round
        require(_choice > 0 && _choice < uint256(4),"Choose a Choice 1 or 2 or 3");

        //should be given allowance of desired tokens to this contract to bet
        require(BSCV._beforeBet(msg.sender,_amount) == true,"check allowance");

        //get current roundID
        uint256 roundId = Controller.getCurrentRoundId();

        //a single address cant place a bet more than once in a round
        require(betAmounts[msg.sender][roundId] == uint256(0),"Bet placed Already in this Round");

        //Authorization
        bool auth = authorize(msg.sender);

        if(auth == true){
            //Getting user id assigned to address
            uint32 userID = userId[msg.sender];

            //Getting Userinfo with userID
            User storage info = users[userID];

            //getting userLevel and betCounts
            (uint32 level,uint256 betCounts) = (info.Level , info.BetCounts);

            //levelManager manages the level of the user
            levelManager(userID,level,betCounts);

            //betManager manages betsPlaced
            (uint256 tax)=betManager(userID,_choice,_amount);

            //returning receipt for bet
            (_userID,amount,result) = (userID,_amount+tax,"Bid Placed");

        }else{
            (_userID,amount,result) = (uint32(0),_amount,"Placing Bid Failed");
        }

    }


    /** * @dev used to bet without any automated checking
    */ 
    function betManager(uint32 _userId,uint256 _choice,uint256 _betAmount)public Approved Free returns(uint256){
        require(_choice > 0 && _choice < uint256(4),"Choose a Choice 1 or 2 or 3");
        require(userId[msg.sender] == _userId,"UserId and calling address is not matched");
        //Get Current RoundID
        uint256 roundId = Controller.getCurrentRoundId();

        //getting Round Info
        round storage spin = rounds[roundId];

        //Bet should be placed before the round time ends
        require(spin.end > uint32(block.number),"Time Over");

        //Place bet if choice was 1
        if(_choice == 1){
        spin.bettingAddressesOnOne.push(msg.sender);
        spin.bettingAmountsOnOne.push(_betAmount);
        }
        //Place bet if choice was 2
        if(_choice == 2){
            spin.bettingAddressesOnTwo.push(msg.sender);
            spin.bettingAmountsOnTwo.push(_betAmount);
        }
        //Place bet if choice was 3
        if(_choice == 3){
            spin.bettingAddressesOnThree.push(msg.sender);
            spin.bettingAmountsOnThree.push(_betAmount);
        }

        //tax on this bet
        uint256 tax = _betAmount*Tax/100;

        //ERC20 transfer betAmount to this contract
        BSCV.transferFrom(msg.sender,address(this),_betAmount);

        //ERC20 transfer taxAmount to Controller contract
        BSCV.transferFrom(msg.sender,address(Controller),tax);

        //add current bet to total prize
        spin.totalPrize += _betAmount;

        //locking the user for restTime blocks
        users[_userId].LockTill = block.number + restTime;

        //increasing the user bet counts
        users[_userId].BetCounts++;

        //saving the bet
        betAmounts[msg.sender][roundId] = _betAmount;

        emit betPlaced(_userId,_choice,_betAmount);
        return tax;
    }
    
    /** * @dev collect rewards you've won
    accessed only by approvedUsers
    */ 
    function collectRewards()public Approved {
        //getting userID
        uint256 userID = userId[msg.sender];
        //getting pendingRewards
        uint256 pending = getPendingRewards(msg.sender);
        if(pending < BSCV.balanceOf(address(this))){
            BSCV.transferFrom(address(this),msg.sender,pending);
        }else{
            Bank.withdraw(msg.sender, pending);
        }
        //transfer the rewards to the user
        //saving the collection action
        users[userID].CollectedRewards += pending;
        users[userID].PendingRewards = uint256(0);
    } 

    /** * @dev returns the roundinfo based on roundId
    */ 
    function getRoundInfo(uint256 _roundId)public view returns( uint256 roundId,
        uint256 start,
        uint256 end,
        address[] memory bettingAddressesOnOne,
        uint256[] memory bettingAmountsOnOne,
        address[] memory bettingAddressesOnTwo,
        uint256[] memory bettingAmountsOnTwo,
        address[] memory bettingAddressesOnThree,
        uint256[] memory bettingAmountsOnThree,
        uint256 winningChoice,
        uint256 totalPrize){
        
        round storage spin = rounds[_roundId];
        roundId = spin.roundId;
        start = spin.start;
        end = spin.end;
        bettingAddressesOnOne = spin.bettingAddressesOnOne;
        bettingAmountsOnOne = spin.bettingAmountsOnOne;
        bettingAddressesOnTwo = spin.bettingAddressesOnTwo;
        bettingAmountsOnTwo = spin.bettingAmountsOnTwo;
        bettingAddressesOnThree = spin.bettingAddressesOnThree;
        bettingAmountsOnThree = spin.bettingAmountsOnThree;
        winningChoice = spin.winningChoice;
        totalPrize = spin.totalPrize;
    }
    
    /** * @dev returns pending Rewards of a user
    */ 
    function getPendingRewards(address _user)public view Approved returns(uint256){
        uint32 userID = uint32(userId[_user]);
        User storage info = users[userID];
        return info.PendingRewards;
    }

    /* ========== External Functions ========== */
    /** * @dev returns number of placed bet in the round
    */ 
    function currentInfo() external view override returns(address[]memory,uint256[]memory,address[]memory,uint256[]memory,address[]memory,uint256[]memory,uint256){
        uint256 roundId = Controller.getCurrentRoundId();
        round storage spin = rounds[roundId];
        return (spin.bettingAddressesOnOne,spin.bettingAmountsOnOne,spin.bettingAddressesOnTwo,spin.bettingAmountsOnTwo,spin.bettingAddressesOnThree,spin.bettingAmountsOnThree,spin.totalPrize);
    }
    
    function currentRound() public view returns(uint256,uint256,uint256){
        uint256 roundId = Controller.getCurrentRoundId();
        round storage spin = rounds[roundId];
        return(spin.roundId,spin.start,spin.end);
    }
    /** * @dev returns a userid registered to the address
    */ 
    function getUserId(address _address)external view override returns(uint32){
        return uint32(userId[_address]);
    }
    
    function getUserAddress(uint32 _id)public view returns(address){
        return userAddress[_id];
    }
    /** * @dev returns user struct of registered userInfo
    */ 
    function getUserInfo(uint32 _userId)external override view returns(uint32 UserID,
        uint32 Level,
        uint256 PendingRewards,
        uint256 CollectedRewards,
        uint256 LockTill,
        uint256 BetCounts,
        bool Approve){
        User storage info = users[_userId];
        UserID = _userId;
        Level = info.Level;
        PendingRewards = info.PendingRewards;
        CollectedRewards = info.CollectedRewards;
        LockTill = info.LockTill;
        BetCounts = info.BetCounts;
        Approve = info.Approved;
    }
    /** * @dev return totalUsers 
    */ 
    function totalUsers()external view override returns(uint256){
        return users.length;
    }
    
    function totalRounds()external view returns(uint256){
        return rounds.length;
    }
    
    /* ========== OnlyControllerFunctions ========== */

    function setWinningChoice(uint256 _choice) external override onlyController {
        uint256 roundId = Controller.getCurrentRoundId();
        round storage spin = rounds[roundId];
        spin.winningChoice = _choice;
    }

    function unapproveUser(uint32 _userId)external override onlyController{
        users[_userId].Approved = false;
    }
    
    function approveUser(uint32 _userId)external override onlyController{
        users[_userId].Approved = true;
    }

    /** * @dev Creates round controlled by owner
    */ 
    function createRound() external override onlyController returns(uint256){
        uint256 roundId = Controller.getCurrentRoundId();
      round memory _round = round({
          roundId: roundId,
          start: uint32(block.number),
          end : uint32(block.number) + Countdown,
          bettingAddressesOnOne: new address[](0),
          bettingAmountsOnOne: new uint256[](0),
          bettingAddressesOnTwo: new address[](0),
          bettingAmountsOnTwo: new uint256[](0),
          bettingAddressesOnThree: new address[](0),
          bettingAmountsOnThree: new uint256[](0),
          winningChoice:  uint256(0),
          totalPrize: uint256(0)
      });
      rounds.push(_round);
      emit roundCreated(roundId);
      return roundId;
    }

    function addRewards(uint256 _userId,uint256 _amounts) external override onlyController{
        users[_userId].PendingRewards += _amounts;
    }
    
    function setCountdown(uint32 _countdown)external override onlyController{
        Countdown =_countdown;
    }
    

    /* ==========OnlyOwner========== */
    function setBSCV(IBSCV _token)public onlyOwner{
        BSCV = _token;
    }
    
    function setController(IController _controller) public onlyOwner{
        Controller =_controller;
    }

    function setRestTime(uint256 _rest)public onlyOwner{
        restTime = _rest;
    }
    
    function setBank(IBANK _bank)public onlyOwner{
        Bank = _bank;
    }

    /* ==========Internal========== */
    function authorize(address _address)internal returns(bool){
       if(userId[_address] == uint32(0)){
           registerUser(_address);
       }
       uint32 userID = userId[_address];
       User storage info = users[userID];
       require(info.LockTill <= block.number,"Wait for sometime Regain some energy");
       require(info.Approved == true,"Unapproved User");
       return (true);
    }
    function registerUser(address _address)internal returns(string memory,uint256){
        uint32 totalUser = uint32(users.length);
        User memory info = User({
        UserID: totalUser,
        Level: uint32(0),
        PendingRewards: uint32(0),
        CollectedRewards: uint256(0),
        LockTill: uint256(0),
        BetCounts: uint256(0),
        Approved: true
        });
        users.push(info);
        userId[_address] = totalUser;
        userAddress[totalUser] = _address;
        return("Created USERID",totalUser);
    }
    function levelManager(uint32 _userId,uint32 _level,uint256 _betCounts)internal{
        bool upgrade = Controller.levelRequirements(_level,_betCounts);
        if(upgrade == true){
            users[_userId].Level++;
        }
    }
    
    modifier Approved{
        require(users[userId[msg.sender]].Approved == true,"Unapproved");
        _;
    }
    modifier Free{
        require(users[userId[msg.sender]].LockTill < block.number,"Wait till Unlocked");
        _;
    }
    modifier onlyController{
        require(msg.sender == address(Controller),"Access denied");
        _;
    }
}