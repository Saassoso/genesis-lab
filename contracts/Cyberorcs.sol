// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import "contracts/Interface/ICyberorcs.sol";

contract Cyberorcs is ICyberorcs {
    string private NAME;
    string private SYMBOL;
    uint256 public immutable MAX_SUPPLY;

    address public minter;
    uint256 public totalSupply;

    mapping(address => uint256) private balance;
    mapping(address => mapping(address => uint256)) private _allowance;

constructor(string memory name_,string memory symbol_,uint256 maxSupply_,address treasury) {
    NAME = name_;
    SYMBOL = symbol_;
    MAX_SUPPLY = maxSupply_;
    balance[treasury] = maxSupply_;
    totalSupply = maxSupply_;
}


    function name() public view returns (string memory) {
        return NAME;
    }

    function symbol() public view returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return 10;
    }

    function totalSupplyView() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return balance[owner];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        require(balance[msg.sender] >= amount, "Cyberorcs: Low Balance");

        balance[msg.sender] -= amount;
        balance[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public returns (bool) {
        require(msg.sender == minter, "Cyberorcs: Access Denied");
        require(totalSupply + amount <= MAX_SUPPLY, "Cyberorcs: Max Supply");

        balance[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        require(balance[msg.sender] >= amount, "Cyberorcs: Low Balance");
        balance[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "CyberOrcs: Zero Address");
        _allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balance[from] >= value, "Cyberorcs: Low Balance");
        require(_allowance[from][msg.sender] >= value, "Cyberorcs: Low Allowance");
        balance[from] -= value;
        balance[to] += value;

        _allowance[from][msg.sender] -= value;

        emit Transfer(from, to, value);
        return true;
    }
}
