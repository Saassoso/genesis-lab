// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import "contracts/Interface/ICyberorcs.sol";
import "contracts/Ownable.sol";

contract Cyberorcs is ICyberorcs, Ownable {
    //metadata
    string private NAME;
    string private SYMBOL;
    uint8 private constant DECIMALS = 18;

    // supply limits
    uint256 public immutable MAX_SUPPLY;
    uint256 public totalSupply;
    address public minter;

     // balances and allowances
    mapping(address => uint256) private _balance;
    mapping(address => mapping(address => uint256)) private _allowance;

    constructor(string memory name_, string memory symbol_, uint256 maxSupply_, address treasury) Ownable(msg.sender) {
        require(treasury != address(0), "Zero treasury");
        NAME = name_;
        SYMBOL = symbol_;
        MAX_SUPPLY = maxSupply_;

        minter = msg.sender; // deployer is initial minter

        // Mint all tokens to treasury initially : didnt work
        // Only mint 50% initially so the mint function works later
        uint256 initialMint = maxSupply_ / 2; 
        
        _balance[treasury] = initialMint;
        totalSupply = initialMint;

        emit Transfer(address(0), treasury, initialMint);
    }

    // ---------------- Metadata functions ----------------
    function name() public view returns (string memory) {
        return NAME;
    }

    function symbol() public view returns (string memory) {
        return SYMBOL;
    }

    function decimals() public pure returns (uint8) {
        return DECIMALS;
    }

    function totalSupplyView() public view returns (uint256) {
        return totalSupply;
    }

    // ---------------- GETTER ----------------------------
    function balanceOf(address owner) public view returns (uint256) {
        return _balance[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }

    // ---------------- Transfer functions ----------------
    function transfer(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 currentAllowance = _allowance[from][msg.sender];
        require(currentAllowance >= value, "Cyberorcs: Low Allowance");
        _allowance[from][msg.sender] = currentAllowance - value;

        _transfer(from, to, value);

        emit Transfer(from, to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "CyberOrcs: Zero Address");
        _allowance[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }
    
    // ---------------- Mint & Burn ----------------
    function mint(address to, uint256 amount) public onlyOwner returns (bool sucess) {
        //require(msg.sender == minter, "Cyberorcs: Access Denied");
        require(to != address(0), "Cyberorcs: Zero recipient");
        require(totalSupply + amount <= MAX_SUPPLY, "Cyberorcs: Max Supply");

        _balance[to] += amount;
        totalSupply += amount;

        emit Transfer(address(0), to, amount);

        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        require(_balance[msg.sender] >= amount, "Cyberorcs: Low Balance");

        _balance[msg.sender] -= amount;
        totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);

        return true;
    }

    // ---------------- Internal helper ----------------
    function _transfer(address from, address to, uint256 amount) internal {
        require(to != address(0), "Cyberorcs: Zero recipient");
        require(_balance[from] >= amount, "Cyberorcs: Low Balance");

        _balance[from] -= amount;
        _balance[to] += amount;
        emit Transfer(from, to, amount);
    }
}
