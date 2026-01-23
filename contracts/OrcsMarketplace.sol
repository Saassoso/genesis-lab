// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.30;

import "contracts/Interface/IOrcsMarketplace.sol";
import "contracts/Interface/ICyberorcs.sol";
import "contracts/Interface/IOrcsNFT.sol";

contract OrcsMarketplace is IOrcsMarketplace {

    ICyberorcs public immutable cyberOrcs;
    IOrcsNFT public immutable orcsNFT;

    mapping(uint256 => Listing) private _listings;

    constructor (address _cyberOrcs, address _orcsNFT) {
        require(_cyberOrcs != address(0), "OrcsMarketplace: invalid Token address");
        require(_orcsNFT != address(0), "OrcsMarketplace: invalid NFT address");
        cyberOrcs = ICyberorcs(_cyberOrcs);
        orcsNFT = IOrcsNFT(_orcsNFT);
    }

    function list(uint256 tokenId, uint256 price) public {
        // check price is not 0
        require(price > 0, "OrcsMarketplace: price must be greater than zero");

        // check the caller is the owner
        require(orcsNFT.ownerOf(tokenId) == msg.sender , "OrcsMarketplace: caller is not the owner");
        // check marketplace is approved
        require (
            orcsNFT.getApproved(tokenId) == address(this) ||
            orcsNFT.isApprovedForAll(msg.sender,address(this)), "OrcsMarketplace: marketplace not approved"
        );


        require(_listings[tokenId].price == 0, "OrcsMarketplace: already listed");

        _listings[tokenId] = Listing({
            price: price,
            seller: msg.sender,
            status: Status.LISTED
            });

        emit Listed(msg.sender, tokenId, price);
    }

    function cancel(uint256 tokenId) public {
        Listing memory listing = _listings[tokenId];
        require(listing.status == LISTED, "OrcsMarketplace: not listed");
        require(listing.seller == msg.sender, "OrcsMarketplace: caller is not the seller");

        delete _listings[tokenId];

        emit Canceled(msg.sender, tokenId);
    }

    function buy(uint256 tokenId) public {
        Listing memory listing = _listings[tokenId];
        require(listing.status == LISTED, "OrcsMarketplace: not listed");
        require(listing.seller != msg.sender, "OrcsMarketplace: cannot buy Own Listing");
        require(cyberOrcs.allowance(msg.send, address(this)) > listing.price, "OrcsMarketplace: not enough allowance");

        listing.status = Status.SOLD;

        orcsNFT.transferFrom(listing.seller, msg.sender, tokenId);
        bool success = cyberOrcs.tranferFrom(msg.sender, listing.seller, listing.price);
        require(success, "OrcsMarketplace: payment failed");

        emit Sold(msg.sender, tokenId);
    } 
    function getListing(uint256 tokenId) external view returns (Listing memory) {
    Listing memory listing = _listings[tokenId];
    return listing;
    }
}