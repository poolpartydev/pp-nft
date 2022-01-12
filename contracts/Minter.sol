// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./libraries/IterableMapping.sol";
import "./libraries/LSDStructs.sol";
import "./interfaces/IMintableERC721.sol";

interface ILSDBag {
    function getBag(uint256 _bagId) external view returns (LSDStructs.BagDataExtended memory) ;
}

contract Minter is Ownable {
    using IterableMapping for IterableMapping.Map;
    mapping (uint256 => uint256) public totalMintedByBag;

    // Mapping of NFT collection to probability of minting it 
    IterableMapping.Map private collectionToProbability;

    // Total probability is sum of all collection probabilities
    uint256 public totalProbability;

    address public LSDBagContract = 0xf29763f1fd0975EfdDbA87b881CE6377872698d0;

    /**
        @notice Adds NFT collection 
        @param _collection Address of the NFT collection
        @param _probability Probability of minting this collection
     */
    function addCollection(address _collection, uint256 _probability) external onlyOwner {
        require(collectionToProbability.get(_collection) == 0, "Collection is already added.");
        require(_probability != 0, "Probability of new collection has to be > 0.");
        collectionToProbability.set(_collection, _probability);
        totalProbability += _probability;
    }

    /**
        @notice Removes NFT collection
        @param _collection Address of the NFT collection
     */
    function removeCollection(address _collection) external onlyOwner {
        totalProbability -= collectionToProbability.get(_collection);
        collectionToProbability.remove(_collection);
    }

    /**
        @notice Updated probability of minting given collection
        @param _collection Address of the NFT collection
        @param _newProbability New probability of minting that collection
     */
    function updateCollectionProbability(address _collection, uint256 _newProbability) external onlyOwner {
        require(collectionToProbability.get(_collection) != 0, "Collection is not added yet.");
        totalProbability -= collectionToProbability.get(_collection);
        collectionToProbability.set(_collection, _newProbability);
        totalProbability += _newProbability;
    }

    /**
        @param _bagId ID of the bag for which the minting will be done
        @param _amount Amount of NFTs that should be minted within transaction
     */
    function mintByBag(uint256 _bagId, uint256 _amount) external {
        require(msg.sender == IERC721(LSDBagContract).ownerOf(_bagId), "Only owner of the bag can mint its NFTs.");
        require(_amount <= availableAmountToMint(_bagId), "This bag is not eligible to mint this amount of NFTs.");
        totalMintedByBag[_bagId] += _amount;
        for(uint256 amountMinted = 0; amountMinted < _amount; amountMinted++) {
            _randomMint(msg.sender);
        }
    }

    /**
        @param _bagId LSD Bag for which we check minting
        @return Amount of NFTs that can be minted for given bag
     */
    function availableAmountToMint(uint256 _bagId) public view returns(uint256) {
        // TODO test this
        uint256 bagCreation = ILSDBag(LSDBagContract).getBag(_bagId).data.createdAt;
        return ((block.timestamp - bagCreation) / 30 days) - totalMintedByBag[_bagId];

    }

    function getCollectionAtIndex(uint256 _index) external view returns (address) {
        return collectionToProbability.getKeyAtIndex(_index);
    }

    function getCollectionProbability(address _collection) external view returns (uint256) {
        return collectionToProbability.get(_collection);
    }

    /**
        @notice Main function of the contract that provides random minting
        @param _reciever Wallet which will get 1 random NFT 
     */
    function _randomMint(address _reciever) private {
        address collection = _randomlyPickCollection();
        IMintableERC721(collection).mint(_reciever);
    }

    /**
        @notice Randomly picks the collection from which the next NFT will be minted
     */
    function _randomlyPickCollection() private returns (address) {
        // returns first added collection
        return collectionToProbability.getKeyAtIndex(0);
        // // TODO get random number in range 0..totalProbability from Chainlink VRF
        // uint256 randomNumber = ;
        // // Iterates through all probabilities and gradually adds them and checks whether 
        // // the picked number is <= actual boundary set by the most recent collection index
        // uint256 collectionIndex = 0;
        // uint256 rangeUpperBoundary = collectionToProbability.getValueAtIndex(collectionIndex);
        // while (rangeUpperBoundary < randomNumber) {
        //     collectionIndex++;
        //     rangeUpperBoundary += collectionToProbability.getKeyAtIndex(collectionIndex);
        // }
        // return collectionToProbability.getKeyAtIndex(collectionIndex);

    }
}