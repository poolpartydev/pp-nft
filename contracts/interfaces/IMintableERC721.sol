//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMintableERC721 {
    function mint(address _reciever) external returns (uint256);
}