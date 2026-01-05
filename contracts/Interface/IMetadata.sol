// SPDX-License-Identifier: IMT
pragma solidity >=0.8.24;

interface IMetadata {
    function name() view external returns (string memory);
    function symbol() view external returns (string memory);
    function baseUri() view external returns (string memory);
    //function myApprovedForAll(address owner, address spender) view public returns(bool);
}