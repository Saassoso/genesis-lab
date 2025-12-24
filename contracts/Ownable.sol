// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

abstract contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    constructor(){
        //_owner = msg.sender;
        //emit OwnershipTransferred(address(0), _owner);
        transferOwnership(msg.sender);
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
}