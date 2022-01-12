// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMintableERC721.sol";
/**
    @title ERC721 contract that is minted by another smart contract
            and has metadata deployed to IPFS
    @author kefas
 */
contract MintableERC721 is ERC721, ERC721Enumerable, IMintableERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;
    
    Counters.Counter private _tokenIds;

    address public mintingContract = 0x5256c14318d050082C11e83DDF245Af4cE78b2d2;
    
    uint256 constant public MAX_SUPPLY = 10000;

    constructor() ERC721("Pool Party Characters", "PPC") {}

    /**
        @notice Main function that mints NFTs
        @param _reciever Address that will recieve the newly minted NFT
        @return ID of the newly minted NFTs
     */
    function mint(address _reciever) external override returns (uint256) {
        require(msg.sender == mintingContract, "NFTs can be minted only by the minting contract.");
        require(_tokenIds.current() < MAX_SUPPLY, "MAX supply was reached, no more NFTs can be minted.");
        _tokenIds.increment();
        uint256 id = _tokenIds.current();
        _safeMint(_reciever, id);
        return id;
    }

    /**
        @notice Set minting contract that can mints new NFTs
        @param _newMintingContract Address of the new minting contract
    */
    function setMintingContract(address _newMintingContract) external onlyOwner {
        mintingContract = _newMintingContract;
    }

    /**
        See ERC721.sol: `_baseURI`
     */
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeieeh25va2riqwwnewxqxrrsmpfhde7cqhl4fp65nhlerurdltmfie/";
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), "/metadata.json")) : "";
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