// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./interfaces/IMintableERC721.sol";
/**
    @title ERC721 contract that is minted by another smart contract
            and has metadata deployed to IPFS
    @author kefas
 */
contract MintableERC721 is ERC721, ERC721Enumerable, IMintableERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address constant public MINTING_CONTRACT = address(0);
    
    uint256 constant public MAX_SUPPLY = 10000;

    constructor() ERC721("Pool Party Characters", "PPC") {}

    /**
        @notice Main function that mints NFTs
        @param _reciever Address that will recieve the newly minted NFT
        @return ID of the newly minted NFTs
     */
    function mint(address _reciever) external returns (uint256) {
        require(msg.sender == MINTING_CONTRACT, "NFTs can be minted only by the minting contract.");
        require(_tokenIds.current() < MAX_SUPPLY - 1, "MAX supply was reached, no more NFTs can be minted.");
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _safeMint(_reciever, id);
        return id;
    }

    /**
        See ERC721.sol: `_baseURI`
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
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