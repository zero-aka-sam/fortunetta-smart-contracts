// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.4;

interface IBSCV is IERC20{
    function mint(address _to,uint256 _amount)external;
    function _beforeBet(address,uint256)external returns(bool);
}