// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Guarded is Context {
    address private _guard;

    event GuardshipTransferred(address indexed previousGuard, address indexed newGuard);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _setGuard(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function guard() public view virtual returns (address) {
        return _guard;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyGuard() {
        require(guard() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceGuardship() public virtual onlyGuard {
        _setGuard(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferGuardship(address newGuard) public virtual onlyGuard {
        require(newGuard != address(0), "Ownable: new owner is the zero address");
        _setGuard(newGuard);
    }

    function _setGuard(address newGuard) private {
        address oldGuard = _guard;
        _guard = newGuard;
        emit GuardshipTransferred(oldGuard, newGuard);
    }
}