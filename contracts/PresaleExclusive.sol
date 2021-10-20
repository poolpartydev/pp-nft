// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PinksaleInterface.sol";

/**
    @notice Simple ERC721 contract for FullPresaleContributor NFT
    @author kefas
 */

contract PresaleExclusive is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public pinksalePresaleAddress = address(0);

    mapping(address => bool) public minted;

    constructor() ERC721("Pool Party Presale Exclusive", "PPPE") {}

    function tokenURI(uint256 tokenId) public view override {
        return
            "ipfs://bafkreiaon23sx26a2g754afl3jyxtsk7zpuno5ryh43uaag4jsz6mtqyza";
    }

    function mintToken() public returns (uint256) {
        require(
            _isEligible(msg.sender),
            "You are not eligible for this exclusive NFT!"
        );
        require(
            !minted[msg.sender],
            "This address already minted exclusive NFT!"
        );

        minted[msg.sender] = true;
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _safeMint(msg.sender, id);

        return id;
    }

    /**
        @notice Returns true if the amount contributed in Pinksale is eq 1 BNB
     */
    function isEligible(address _purchaser) external view returns (uint256) {
        return _isEligible(_purchaser);
    }

    /**
        @notice Returns true if the amount contributed in Pinksale is eq 1 BNB
     */
    function _isEligible(address _purchaser) private view returns (bool) {
        return PinkSale(pinksalePresaleAddress).contributionOf == 10**18;
    }
}
