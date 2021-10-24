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

    address public pinksalePresaleAddress = 0x7d97c30E59F0c3108abf8a6Ed62B1B7A8a0BCa5c;

    mapping(address => bool) public phase1Contributors;

    mapping(address => bool) public minted;

    constructor() ERC721("Pool Party Presale Exclusive", "PPPE") {
        _initializePhase1Contributors();
    }

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
            "ipfs://bafyreid4oaqjtftsgwrl2ryh7ivk3mrntuonqnjjz5m4jp4fzpjiargtae/metadata.json";
            
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
        return PinkSale(pinksalePresaleAddress).contributionOf(_purchaser) == 10**18 || phase1Contributors[_purchaser];
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

    /**
        @notice Sets phase 1 contributors as it's not possible to get those from 
                the phase 1 presale address
     */
    function _initializePhase1Contributors() private {
        address[40] memory contributors = [0xA695310Cdcdc92356E97EBfdfd3F1d43d0D081EA, 0x977c95A615B5360a69aDc5ae41c0a40d35991965, 0x11858e2b765e42060679180C68C055Df9adA3dec, 0x1f6C9f16C9Cb24eFe448A13416B14D4e541128dD, 0x66D31cb1f84042196C19B5C04Fdf04bE3cE576C1, 0x0B535085Eb827FB18c886917f0a9ac814017aA24, 0x25aB9504044071a95bE64638fD4d2c445b88685B, 0x0cf0cEc497a5E3490939754c4De4FbdAe0E15127, 0x744f617343F03bB7C9d52A6D84F87Aa4b1017fAc, 0x8585d1F5f7CE8E08D2ecFae64275a9391Ed6D327, 0x55CEED29F8B444BA7AB8314D68B9151A0eCE2C87, 0xA9c33B33Af132D8b15993C4CE8b441732FAb45Ce, 0x547926344e4ef59121107b16bBE13c087384A801, 0xACc4acf420AcE720D7F2FACb3f58A38dA219df43, 0xA926283783eAe84D3E3fc31bAB2d08F8C44A34b7, 0x2b23E4E377f2494955089040c1d56A116cF55956, 0x614F2265b9132DB4De22B36af805e16890C94515, 0xc66040ba323589b542031cB153FF08Cb9198E75F, 0x600e262Df5dFf3A79eFFAF024CbD20c5835A01bB, 0xd8BfbBA1B09CFf3c5D7fCF8773D7D73EAE354aD1, 0xC730a5933e11403aB3661F3883Ae654Ad752eE08, 0x1fcBAAFA4f8d94974f74F0D30045FE8f2e3Dfd7e, 0x8694C01024cB03f38f4329C3AAC0c264367F7E74, 0xE421FA997a6AC2B4921738fef74d8A8839F95884, 0x4375AD7DFde1E7fb5F9e182B4ee3D0A7c5E2E237, 0x2106F85b60EE9419096820EddEE1651ab3d19619, 0x5c8D308DD19cd35C5d6F0eDF2B8f3DF7E4110035, 0x93682CFfBE562C8ccb82eDD738fE9301a0b9b535, 0xB39256e8477197bcBb4dd94B4beB628065F0E0B6, 0x726a2fFe58a4B289a4d350A63c1e3d39BbBE7e0d, 0x729e26F4D152FD4d30495205CA1e2FB682c6262A, 0xb928072f550e94C19a0f2484Ea6c4a2F85c0Cd6D, 0x6FC7cf1D3dD6Fea173D7dCa4F1Ab73EB11Ba8105, 0xE92097c7D33A54E2018f09A5BD10dC8b827d4353, 0x7B5bb49F34343E87165A92f119a68517E98D348A, 0x7042fb13Da04C495Ea9a5804cCADD18830E516F8, 0x4Bfd2741fBcfaD6f70C82bA78DfcD7E00dF59Ccb, 0x10D2Ba1e36C11D53CAd34211C8484E27BAdc548c, 0xCa12Fa9C6AF9ef9ea0e516D6230721aC879AB7dC, 0x029b2D31bc04aF97f8B234bf2E32D0cBb1A59951];
        for(uint256 index; index < contributors.length; index++) {
            phase1Contributors[contributors[index]] = true;
        }
    }
}
