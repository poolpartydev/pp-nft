// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LSDStructs {    
    struct Bag {
        uint48 createdAt;
        uint48  nextPayoutIndex; // index of the next payout
        address tokenAddress;
        uint128 balance;
        uint128 totalDividendsPaid;
    }

    /**
        @notice Used in `getBagsOwnedBy` function
     */
    struct BagData{
            uint256 bagId;
            Bag data;
    }

    /**
        @notice Used in `getBagsOwnedBy` function
     */
    struct BagDataExtended{
            uint256 bagId;
            Bag data;
            AttachedNFT nft;
    }

    struct TokenBagDetails {
        uint8 isAllowed;
        uint8 knottingFee;
        uint8 unknottingFee;
        uint8 multiplier;
        uint224 minBagAmount;
        address dividendTrackerAddress;
    }

    struct Payout{
        uint48 paidAt;
        uint8 totalMultiplier;
        uint200 totalDividends;
    }  

    struct PayoutTokenDetails{
        uint248 totalShares;
        uint8 multiplier;
    }

    struct AttachedNFT{
        bool isERC721Type;
        address tokenAddress;
        uint256 tokenId;
    }

    /**
        @notice LSD Fund distribution in percents
     */
    struct LSDFundDistribution {
        uint8 dividends;
        uint8 burn;
        uint8 compound;
        uint8 marketing;
        uint8 liquidity;
    }

    /**
        @notice Struct for retrieving LSD Fund assets' data
        @dev Is used only in view function, therefore there's no need for packing
     */
    struct LSDFundAsset {
        address assetAddress;
        address masterchefAddress;
        uint256 balance;
    }
    
    struct TotalTokenShares {
        address tokenAddress;
        uint256 totalShares;
    }

}