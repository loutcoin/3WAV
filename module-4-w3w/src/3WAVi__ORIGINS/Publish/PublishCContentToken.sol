// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
/*import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";*/
import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";
/*import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";*/
/*import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";*/

import {
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearch.sol";

import {
    LibPublishCContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSupplies.sol";

contract PublishCContentToken {
    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    error PublishCContentToken__NumInputInvalid();

    /*
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _cSupplyVal Unsigned interger containing the collection supply data.
     * @param _sPriceUsdVal Unsigned interger containing seperate sale price properties.
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
     * @param _sSupplyVal Unsigned interger containing Content Token supply data.
     * @param _sReserveVal Unsigned interger containing seperate sale reserve values.
     * @param _cReleaseVal Unsigned interger containing timestamp publication data.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCContentToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint32 _cPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint96 _cReleaseVal,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap,
        uint256[] calldata _tierMapPages //uint256[] calldata _stateMapPages **Deprecated Currently*
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_numToken == 0 || _cSupplyVal == 0)
            revert PublishCContentToken__NumInputInvalid();
        // Storage locals
        /*ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage(); */

    /*CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();*/

    /*ContentTokenSearchStruct.s_cContentTokenSearch[
            _hashId
        ] = CContentTokenStorage.CContentToken({
            numToken: _numToken,
            cSupplyVal: _cSupplyVal,
            sPriceUsdVal: _sPriceUsdVal,
            cPriceUsdVal: _cPriceUsdVal,
            sSupplyVal: _sSupplyVal,
            sReserveVal: _sReserveVal,
            cReleaseVal: _cReleaseVal
        });*/

    /*_publishCContentTokenSearch(
            _hashId,
            _numToken,
            _cSupplyVal,
            _sPriceUsdVal,
            _cPriceUsdVal,
            _sSupplyVal,
            _sReserveVal,
            _cReleaseVal
        );

        LibPublishCreatorToken._publishCreatorToken(
            _creatorId,
            _hashId,
            _numToken
        );

        // Needs update
        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSupplies(
            _hashId,
            _cSupplyVal,
            _sSupplyVal,
            _sReserveVal,
            _tierMapPages
            //_stateMapPages
        );

        // enable bitmap and stuff glossed over should be incorporated
        if (_numCollaborator > 0) {
            /*CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;*/
    /*_publishCContentTokenCollaboratorMap(
                _hashId,
                _numCollaborator,
                _royaltyVal,
                _royaltyMap
            );
        }

        emit CContentTokenPublished(_creatorId, _hashId, _numToken);
    }*/

    // FacetHelpers/LibPublishCContentTokenSearch
    // We might not need several of these imports anymore, including for example:
    // CContentTokenStorage, CContentTokenSearch, Collaborator, etc;
    /*function _publishCContentTokenSearch(
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint32 _cPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint96 _cReleaseVal
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        ContentTokenSearchStruct.s_cContentTokenSearch[
            _hashId
        ] = CContentTokenStorage.CContentToken({
            numToken: _numToken,
            cSupplyVal: _cSupplyVal,
            sPriceUsdVal: _sPriceUsdVal,
            cPriceUsdVal: _cPriceUsdVal,
            sSupplyVal: _sSupplyVal,
            sReserveVal: _sReserveVal,
            cReleaseVal: _cReleaseVal
        });
    }

    function _publishCContentTokenCollaboratorMap(
        bytes32 _hashId,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) internal {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        CollaboratorMapStruct.s_collaborators[
            _hashId
        ] = CollaboratorStructStorage.Collaborator({
            numCollaborator: _numCollaborator,
            royaltyVal: _royaltyVal
        });
        CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
        CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
    }*/

    /*function publishCContentTokenCollaboratorStructMapping(
        bytes32 _hashId,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256 _royaltyMap
    ) internal {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();
        
    }*/

    // possibly make just single Collaborator and loop thru. Sounds inefficient but I believe that's
    // what we already do in PublishCContentTokenBatch.sol

    // This will be new updated publishCContentToken obviously

    /*
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    /*function _publishCContentTokenTest(
        address _creatorId,
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ReturnValidation.returnIsAuthorized();

        if (_cContentToken.numToken == 0 || _cContentToken.cSupplyVal == 0)
            revert PublishCContentToken__NumInputInvalid();

        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSuppliesTest(
            _hashId,
            _cContentToken,
            _tierMapPages,
            _priceMapPages
        );

        LibPublishCContentTokenSearch._publishCContentTokenStackTest(
            _creatorId,
            _hashId,
            _cContentToken,
            _collaborator
        );

        emit CContentTokenPublished(
            _creatorId,
            _hashId,
            _cContentToken.numToken
        );
    }*/

    /**
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * Function Selector: 0x960b4eca
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCContentToken(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSupplies(
            _creatorToken,
            _cContentToken,
            _tierMapPages,
            _priceMapPages
        );

        LibPublishCContentTokenSearch._publishCContentTokenSearch(
            _creatorToken,
            _cContentToken,
            _collaborator
        );
    }
}

// "publishCContentToken((address,uint256,bytes32),(uint16,uint112,uint112,uint32,uint224,uint160,uint96), (uint8,uint128,uint256[]),uint256[],uint256[])"
// Selector: 0x960b4eca
