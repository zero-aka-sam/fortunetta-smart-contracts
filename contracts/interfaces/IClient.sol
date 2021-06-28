// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IClient{
    function currentInfo() external view returns(address[]memory,uint256[]memory,address[]memory,uint256[]memory,address[]memory,uint256[]memory,uint256);
    function setWinningChoice(uint256) external;
    function createRound() external returns(uint256);
    function unapproveUser(uint32 _userId)external;
    function approveUser(uint32 _userId)external;
    function getUserId(address)external view returns(uint32);
    function addRewards(uint256  _userId,uint256 _amounts) external;
    function totalUsers()external returns(uint256);
    function getUserInfo(uint32 _userId)external view returns(uint32 UserID,
        uint32 Level,
        uint256 PendingRewards,
        uint256 CollectedRewards,
        uint256 LockTill,
        uint256 BetCounts,
        bool Approve);
    function setCountdown(uint32 _countdown)external;
}