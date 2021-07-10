pragma solidity 0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import './interfaces/IBSCV.sol';
import './interfaces/IBANK.sol';


contract Bank is Ownable,IBANK{
    IBSCV public BSCV;

    mapping(uint256 => mapping(uint256 => address))public withdrawStatement; 

    uint256 public totalWithdrawals;

    function withdraw(address _to,uint256 _amount)external override {
        BSCV.transfer(_to,_amount);
        withdrawStatement[totalWithdrawals][_amount]= msg.sender;
        totalWithdrawals ++;
    }  

    function setBSCV(IBSCV _bscv)public onlyOwner{
       BSCV = _bscv;
    }
}