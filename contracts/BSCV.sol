// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IClient.sol";

import "./interfaces/IBSCV.sol";
import "./interfaces/IBANK.sol";
import "./interfaces/IController.sol";

pragma solidity 0.8.4;

contract BSCV is Ownable,ERC20("BSCGamble","BSCV"),IBSCV{
    /* ========== States ========== */
    IClient public Client;

    IBANK public Bank;
    
    /* ========== Constructor ========== */
    constructor(IBANK _bank){
        Bank = _bank;
        _mint(address(_bank),uint256(100000000000000000000000000));
    }

    /* ========== Functions ========== */
    /** * @dev mint desired number of tokens to the address 
    Only accessible by Client contract */ 
    // function mint(address _to,uint256 _amount)external override onlyOwner{
    //     _mint(_to,_amount);
    // }
    
    //free token development purposes
    
    function mint(address _to,uint256 _amount)external override {
         _mint(_to,_amount);
     }
    

    /** * @dev _beforeBet, a checking function that is 
    called during bet which returns bool*/ 
    function _beforeBet(address _from,uint256 _amount) external view override returns(bool result){
        require(balanceOf(_from) >= _amount,"low balance");
        if(allowance(_from,address(Client)) >= _amount){
            result = true;
        }else{
            result = false;
        }
    }

    /** * @dev allows to change Bank contract accessible only by owner*/ 
    function setBank(IBANK _bank)public onlyOwner{
        Bank = _bank;
    }
     function setClient(IClient _client)public onlyOwner{
        Client = _client;
    }


    /* ========== modifiers ========== */
    modifier onlyClient{
        require(msg.sender == address(Client),"Access denied");
        _;
    }
}

