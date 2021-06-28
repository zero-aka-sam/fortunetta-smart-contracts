// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

interface IController{
    function levelRequirements(uint256,uint256)external view returns(bool);
    function getCurrentRoundId()external view returns(uint256);
}