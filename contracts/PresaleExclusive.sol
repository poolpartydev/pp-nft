// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./PinksaleInterface.sol";

/**
    @notice Simple ERC721 contract for FullPresaleContributor NFT
    @author kefas
 */

contract PresaleExclusive is ERC721, ERC721Enumerable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address public pinksalePresaleAddress = 0x4C45918Ea5bAD138e66EDD02eF6Ae87Af55E5830;

    mapping(address => bool) public minted;

    constructor() ERC721("Pool Party Presale Exclusive", "PPPE") {}

    /**
        @notice Mints NFT if the msg.sender is eligible and hasn't minted their NFT yet
     */
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
        @return URI with NFT metadata, the metadata are same for each token
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return
            "ipfs://ipfs://bafyreigdkhlxq4xhk4p52cxpti26dhtiphgvqmabzh473jmfhzgw3yax34/metadata.json";
    }

    /**
        @notice Returns true if the amount contributed in Pinksale is eq 1 BNB
     */
    function isEligible(address _purchaser) external view returns (bool) {
        return _isEligible(_purchaser);
    }


    /**
        @notice Returns true if the amount contributed in Pinksale is eq 1 BNB
     */
    function _isEligible(address _purchaser) private view returns (bool) {
        return PinkSale(pinksalePresaleAddress).contributionOf(_purchaser) == 10**18;
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
