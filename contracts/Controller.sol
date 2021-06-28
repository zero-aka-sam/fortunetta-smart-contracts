// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "./interfaces/IController.sol";
import "./interfaces/IBSCV.sol";
import "./interfaces/IClient.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./lib/Guarded.sol";


contract Controller is IController,Guarded{
    using Counters for Counters.Counter;
    //address of the operator
    address public operator;

    //address of the Client
    IClient public Client;

    //address of the ERC20
    IBSCV public BSCV;

    //mapping of levelConditions used to upgrade levels
    mapping(uint256 => uint256)levelConditions;

    //mapping of levelMultiplier used in distributing daily rewards based on level
    mapping(uint256 => uint256)levelMultiplier;

    //Round index
    Counters.Counter public Round;
    
    //timestamp used to know the nextDailyReward
    uint256 public nextdailyRewardAt;
    //dailyReward base amount
    uint256 public dailyRewards = uint256(10*10**18);
    //dailyRewardInterval
    uint256 public dailyRewardInterval = uint256(1 days);
    
    event finishedRound(uint256 _id);
    
    constructor(address _operator,IClient _client,IBSCV _bscv){
        operator = _operator;
        Client = _client;
        BSCV = _bscv;
        levelConditions[0] = 2;
        levelConditions[1] = 6;
        levelConditions[2] = 8;
        levelConditions[3] = 12;
        levelConditions[4] = 15;
        levelMultiplier[0] = 0;
        levelMultiplier[1] = 1;
        levelMultiplier[2] = 2;
        levelMultiplier[3] = 3;
        levelMultiplier[4] = 4;
        
        nextdailyRewardAt = block.number + 10;
    }
    /* ========== OnlyOperator Functions ========== */
    function createRound()public onlyOperator returns(uint256 roundId){
        roundId = Client.createRound();
    }

     /** * @dev finishtheRound based on random choice called via operator
    */ 
    function finishRound(uint256 _choice)public onlyOperator{
        require(_choice > 0 && _choice < uint256(4));
         (address[] memory oneAddress,uint256[] memory oneAmounts,
         address[] memory twoAddress,uint256[]memory twoAmounts,
         address[]memory threeAddress,uint256[]memory threeAmounts,uint256 total) = Client.currentInfo();
         
        if(_choice == 1){
            (uint32[] memory ids,uint256[] memory payments)= processPaymentInfo(oneAddress,oneAmounts,total);
             Client.setWinningChoice(1);
            for(uint256 i=0 ; i < oneAddress.length ; i++){
               Client.addRewards(ids[i],payments[i]);
            }
        }
        if(_choice == 2){
            (uint32[] memory ids,uint256[] memory payments)= processPaymentInfo(twoAddress,twoAmounts,total);
             Client.setWinningChoice(2);
            for(uint256 i=0 ; i < twoAddress.length ; i++){
               Client.addRewards(ids[i],payments[i]);
            }
        }
        if(_choice == 3){
            (uint32[] memory ids,uint256[] memory payments)= processPaymentInfo(threeAddress,threeAmounts,total);
             Client.setWinningChoice(3);
            for(uint256 i=0 ; i < threeAddress.length ; i++){
               Client.addRewards(ids[i],payments[i]);
            }
        }
        Client.createRound();
        emit finishedRound(Round.current());
        Round.increment();
    }

    /** * @dev Change to newClient
    */
    function setClient(IClient _client)public onlyOperator{
        Client = _client;
    }
    
    function distributeDailyReward()external onlyOperator{
        require(nextdailyRewardAt <= block.number,"Not Yet");
        uint256 totalUsers = Client.totalUsers();
        for(uint32 i=0;i<totalUsers;i++){
           (,uint256 level,,,,,bool Approved) = Client.getUserInfo(i);
           if(level != 0 && Approved == true){
              Client.addRewards(i,dailyRewards*levelMultiplier[level]);
            }else{
                continue;
            }
        }
        nextdailyRewardAt = block.number + dailyRewardInterval;
    }

    /* ========== OnlyGuard Functions ========== */
    
    /** * @dev edit the level conditions 
       @param _level choose a level to edit its condition
       @param _condition enter the condition to be changed
       Use this function wisely as this would messup the levels of the users and other level requirements
    */
    function editLevel(uint256 _level,uint256 _condition)public onlyGuard returns(string memory message){
        levelConditions[_level] = _condition;
        return("Level condition changed");
    }

    /** * @dev Change ERC20
    */
    function setBSCV(IBSCV _token)public onlyGuard{
        BSCV = _token;
    }

    /** * @dev Change operator
    */
    function setOperator(address _operator)public onlyGuard{
        operator = _operator;
    }

    function withdrawRevenue(address _withdraw)public onlyGuard{
        BSCV.transferFrom(address(this),address(_withdraw),BSCV.balanceOf(address(this)));
    }
    
    function changeUserStatus(address _user,bool _approved)public onlyGuard{
        uint32 Userid = Client.getUserId(_user);
        if(_approved == true){
            Client.approveUser(Userid);
        }else{
            Client.unapproveUser(Userid);
        }
    }

    function setCountDown(uint32 _countDown)public onlyGuard{
        Client.setCountdown(_countDown);
    }


    /* ========== External Functions ========== */

    /** * @dev returns true when the levelrequirements met by the user.Used by levelManager
    */
    function levelRequirements(uint256 _level,uint256 _betCounts)external view override returns(bool _result){
        uint256 level = _level;
        if(levelConditions[level] == _betCounts){
            _result = true;
        }else{
            _result = false;
        }
    }
    /** * @dev returns the current roundId
    */
    function getCurrentRoundId()external view override returns(uint256){
        return Round.current();
    }

    /* ========== Internal Functions ========== */
    function processPaymentInfo(address[]memory _addresses,uint256[]memory _amounts,uint256 _totalAmount)view internal returns(uint32[]memory,uint256[] memory){
      uint256 total = 0;
      uint256[] memory prizeAmounts = new uint256[](_addresses.length);
      uint32[] memory ids = new uint32[](_addresses.length);
      for(uint256 i = 0;i< _addresses.length;i++){
          total += _amounts[i];
          ids[i] = Client.getUserId(_addresses[i]);
      }
      for(uint256 j = 0; j < _addresses.length;j++){
          //uint256 x = _amounts[j]/total*100;
          uint256 x =(_amounts[j]/total)*(100);
          prizeAmounts[j]=(x/100*_totalAmount);
      }
      return (ids,prizeAmounts);
    }
  
    modifier onlyOperator{
        require(msg.sender == operator,"access denied");
        _;
    }
}