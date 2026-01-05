// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import "contracts/Interface/IOrcsNFT.sol";
import "contracts/Interface/IMetadata.sol";
import {IERC721Receiver} from "contracts/Interface/IERC721Receiver.sol";
import "contracts/Ownable.sol";


contract OrcsNFT is IOrcsNFT,IMetadata, Ownable {

    string public name; // function name() view external returns (string memory);
    string public symbol; // function symbol() view external returns (string memory);
    string public baseUri; // function baseUri() view external returns (string memory);

    mapping (address => uint256) public myBalances; //funtion myBalances(address owner ) view public (uint256);
    mapping (address => uint256) private _balances;
    mapping (uint256 => address) private _owners;
    mapping (uint256 => address) private _operators;
    mapping (address => mapping (address => bool)) private _approvedForAll;
    mapping (uint256 => string) public tokenURI;

    //mapping (address => mapping (address => bool)) private myApprovedForAll; // function myApprovedForAll(address owner, address spender) view public returns(bool);
    //mapping (address => mapping (address => mapping (address => booll)) 

    /*function myApprovedForAll(address owner, address spender) view public returns(bool){
        return _approvedForAll[spender][owner];
    }*/

    constructor (string memory _name, string memory _symbol,address _initialOwner) Ownable(_initialOwner) {
        name = _name;
        symbol = _symbol;
    }
    
    //TODO tokenURI: tokenId -> carachteristics (off-chain. uri/url)\
    
    function tokenUri(uint256 _tokenId) public view returns (string memory){
        //require(_tokenId <= MAX_TOKEN, "OrcsNFT: NFT Doeant Exist");
        address owner = _owners[_tokenId];
        require(owner != address(0), "OrcsNFT: NFT Doeant Exist");
        
        return string.concat(
            baseTokenURI,
            Strings.toString(_tokenId)
        );
    }
    

    event TokenURIAdded(uint256 _tokenId, string _tokenURI);

    function setTokenUri(uint256 _tokenId, string calldata _tokenURI) public onlyOwner {
        tokenURI[_tokenId] = _tokenURI;
        emit TokenURIAdded(_tokenId, _tokenURI);
    }

    //TODO mint function
    function mint(address _to, uint256 _tokenId ) public onlyOwner {
        require(_tokenId <= MAX_TOKEN, "OrcsNFT: NFT Doeant Exist");
        require(_to == address(0), "Orcs: minting to zero address");
        require(_owners[_tokenId] == address(0), "OrcsNFT: Token Already exist");
        _balances[_to] += 1;
        _owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    function burn(uint256 _tokenId) public {
        address owner = _owners[_tokenId];
        require(_owners[_tokenId] == msg.sender, "OrcsNFT: caller is not owner");

        _balances[msg.sender] -= 1;
        //_owner[_tokenId] = address(0);

        delete _owners[_tokenId];

        approve(address(0), _tokenId);

        emit Transfer(owner,address(0), _tokenId);
    }

    //TODO Access control

    

    function balanceOf(address _owner) public view returns (uint256){
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner){
        return _owners[_tokenId];

        require(owner != address(0), "OrcsNFT: Token does not exist");
    }

    function getApproved(uint256 _tokenId) public view returns (address){
        return _operators[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _approvedForAll[_owner][_operator];
    }

    function approve(address _approved, uint256 _tokenId) external payable{
        address _owner = ownerOf(_tokenId);
        require(ownerOf(_tokenId) == msg.sender, "OrcsNFT: Not Owner");
        _operators[_tokenId] = _approved;
        emit Approval(_owner, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external{
        require(balanceOf(msg.sender) > 0, "OrcsNFT: No Balance");
        _approvedForAll[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        address _owner = ownerOf(_tokenId);
        require(_from == _owner, "OrcsNFT: From not Owner");
        address _approved = getApproved(_tokenId);
        require(msg.sender == _owner || msg.sender == _approved || isApprovedForAll(_from, msg.sender), "OrcsNFT: From not authorized");
        _balances[_from] -= 1;
        _balances[_to] += 1;
        _owners[_tokenId] = _to;
        _operators[_tokenId] = address(0);

        emit Transfer(_from, _to, _tokenId);

    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable{
        _transfer(_from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory _data) public payable{
        _transfer(_from, _to, _tokenId);

        if(_to.code.length > 0 ){
            IERC721Receiver nftReceiver = IERC721Receiver(_to);
            bytes4 resp = nftReceiver.onERC721Received(msg.sender, _from, _tokenId, _data);
            require( resp == bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")));
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable{
        safeTransferFrom(_from, _to, _tokenId, "0x");
    }


}