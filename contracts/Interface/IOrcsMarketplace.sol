// SPDX-License-Identifier: IMT
pragma solidity >=0.8.24;

interface IOrcsMarketplace {

    enum Status {
        UNLISTED,
        LISTED,
        CANCELLED,
        SOLD
    }

    struct Listing {
        uint256 price;
        address seller;
    }
    // events
    event Listed (address indexed seller, uint256 indexed tokenId, uint256 price);

    event Cancelled (address indexed seller, uint256 indexed tokenId);

    event Sold(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 price);

    // List NFT
    function list(uint256 tokenId, uint256 price) external;

    // Cancel Listing
    function cancel(uint256 tokenId) external;

    // Buy NFT 
    function buy(uint256 tokenId) external payable ;

    // Get NFT Listing
    function getListing(uint256 tokenId) external view returns (Listing memory) ;
}