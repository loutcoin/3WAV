// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";

library ReturnMapMapping {
    /**
     * @notice Retrieves the remaining publically available supply for a token asset.
     * @dev Returns data in 's_cWavSupplies' from 'TokenBalanceStorage.sol'.
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @return _cWavSupplies Remaining collection supplies.
     */
    function returnCWavSupplies(
        bytes32 _hashId
    ) internal view returns (uint112 _cWavSupplies) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        return ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];
    }

    /**
     * @notice Retrieves the remaining publically available supply for a token asset.
     * @dev Returns data in 's_sWavSupplies' from 'TokenBalanceStorage.sol'.
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @param _tierId Tier index attributed to numToken of CContentToken hashId.
     * @return _sWavSupplies Remaining collection supplies.
     */
    function returnSWavSupplies(
        bytes32 _hashId,
        uint16 _tierId
    ) internal view returns (uint112 _sWavSupplies) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        return ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];
    }

    function returnSPriceMap(
        bytes32 _hashId,
        uint16 _page
    ) internal view returns (uint256 _priceMap) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        return ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][_page];
    }

    function _returnCollaboratorReserve(
        bytes32 _hashId,
        uint16 _numToken
    ) internal view returns (uint256 _value) {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStructStorage = CollaboratorMapStorage
                .collaboratorMapStorage();

        return
            CollaboratorMapStructStorage.s_collaboratorReserve[_hashId][
                _numToken
            ];
    }

    /*
     * @notice Retrieves association data between two Content Tokens.
     * @dev Returns data in 's_inAssociation from 'InAssociationStorage.sol'.
     *      Function Selector: 0x5f379ad8
     * @param _hashId Identifier of Content Token being queried.
     * @return Collaborator Local instance of the Collaborator struct
     */
    /*function returnCollaborators(
        bytes32 _hashId
    ) internal view returns (CollaboratorStructStorage.Collaborator memory) {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();
        return CollaboratorMapStruct.s_collaborators[_hashId];
    }*/

    /*
     * @notice Retrieves association data between two Content Tokens.
     * @dev Returns data in 's_inAssociation from 'InAssociationStorage.sol'.
     *      Function Selector: 0x73f7883d
     * @param _hashId Identifier of Content Token being queried.
     * @param _associationIndex an incremental index for defining groupings of tokens published in different contexts and times.
     * @return _associatedHash HashId defined in association to input hash.
     */
    /*function returnInAssociation(
        bytes32 _hashId,
        uint32 _associationIndex
    ) internal view returns (bytes32 _associatedHash) {
        AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();
        _associatedHash = AssociatedContentStruct.s_inAssociation[_hashId][
            _associationIndex
        ];
        return _associatedHash;
    }*/

    /*
     * @notice Retrieves an incremental index count related to user asset ownership.
     * @dev Returns data in 's_ownershipIndex' from 'CreatorTokenMapStorage.sol'.
     *      Function Selector: 0x5b3074cd
     * @param _userId The address associated to the index count.
     * @return _indexCount ownership index of the user
     */
    /*function returnOwnershipIndex(
        address _userId
    ) internal view returns (uint256 _indexCount) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        return CreatorTokenMapStruct.s_ownershipIndex[_userId];
    }

    /**
     * @notice Retrieves an incremental index count related to user asset ownership.
     * @dev Returns data in 's_ownershipMap' from 'CreatorTokenMapStorage.sol'.
     *      Function Selector: 0xe759bb43
     * @param _userId The address associated to the index count.
     * @param _indexCount Chronological index of asset-type ownership associated to an address.
     * @return _hashId Identifier of Content Token being queried.
     */
    /*function returnOwnershipMap(
        address _userId,
        uint256 _indexCount
    ) internal view returns (bytes32 _hashId) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        /*_numToken = CreatorTokenMapStruct.s_ownershipMap[_userId][_indexCount][
            _hashId
        ];
        return _numToken;*/
    /*    _hashId = CreatorTokenMapStruct.s_ownershipMap[_userId][_indexCount];
        return _hashId;
    }

    function returnOwnershipToken(
        address _userId,
        uint256 _indexCount
    ) internal view returns (uint16 _numToken) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();

        _numToken = CreatorTokenMapStruct.s_ownershipToken[_userId][
            _indexCount
        ];
        return _numToken;
    }*/

    /*
     * @notice Retrieves basic token identifier data derived from 'CreatorToken'.
     * @dev Returns data in 's_publishedTokenData' from 'CreatorTokenMapStorage.sol'.
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @return CreatorToken instance-specific token identifier properties.
     */
    /*function returnPublishedTokenData(
        bytes32 _hashId
    ) internal view returns (CreatorTokenStorage.CreatorToken memory) {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        return CreatorTokenMapStruct.s_publishedTokenData[_hashId];
    }*/

    /*
     * @notice Retrieves an asset-type token balance of an address.
     * @dev Returns data in 's_tokenBalance' from 'TokenBalanceStorage.sol'.
     *      Function Selector: 0x86fae71e
     * @param _userId The address of the balance being inquired.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @return _tokenBalance Content Token balance of user.
     */
    /*function returnTokenBalance(
        address _userId,
        bytes32 _hashId,
        uint16 _numToken
    ) internal view returns (uint256 _tokenBalance) {
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();
        _tokenBalance = TokenBalanceStruct.s_tokenBalance[_userId][_hashId][
            _numToken
        ];
        return _tokenBalance;
    }*/

    /*function returnTierMap(
        bytes32 _hashId,
        uint16 _wordIndex
    ) internal view returns (uint256) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[_hashId][
            _wordIndex
        ];
        return _packed;
    }*/
}
