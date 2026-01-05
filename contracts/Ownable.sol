// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "contracts/Interface/IERC173.sol";

abstract contract Ownable is ERC173 {

    address private _owner;

    //event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor(address _initialOwner){
        //_owner = msg.sender;
        //emit OwnershipTransferred(address(0), _owner);
        transferOwnership(_initialOwner);
    }

    function owner() public view returns (address){
        return _owner;
    }

    // definir logic exe avec contract
    modifier onlyOwner() {
        require(msg.sender == owner(), "Ownable: Caller is not the Owner");
        _;
    }

    function _transferOwnership(address _newOwner) internal {
        address oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(oldOwner,_newOwner);
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is zero address");
        _transferOwnership(_newOwner);
    }

    function renounceOwnership() public onlyOwner {
        _transferOwnership(address(0));
    }
}