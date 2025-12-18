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
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";
/*import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";*/
/*import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";*/

import {
    LibPublishCContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSupplies.sol";
/*import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";*/
import {
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishVariantHelper.sol";

contract PublishCVariant {
    event CVariantPublished(
        address indexed creatorId,
        bytes32 indexed baseHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    error PublishCContentToken__NumInputInvalid();

    /**
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _baseHashId The Content Token associated to a derivative Variant.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _cSupplyVal Unsigned interger containing Content Token price definition.
     * @param _sSupplyVal Unsigned interger containing Content Token supply data.
     * @param _sReserveVal Unsigned interger containing seperate sale reserve values.
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
     * @param _cReleaseVal Unsigned interger containing timestamp publication data.
     * @param _variantIndex Numerical index correlating to the total Variant count of a Content Token.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCVariant(
        address _creatorId,
        bytes32 _baseHashId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint32 _cPriceUsdVal,
        uint96 _cReleaseVal,
        uint16 _variantIndex,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap,
        uint256[] calldata _tierMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();
        if (_numToken == 0 || _cSupplyVal == 0 || _variantIndex == 0)
            revert PublishCContentToken__NumInputInvalid();

        // Storage locals
        /*ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();*/

    /*CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();*/

    /*AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();

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

    /*LibPublishCContentTokenSearch._publishCContentTokenSearch(
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

        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSupplies(
            _hashId,
            _cSupplyVal,
            _sSupplyVal,
            _sReserveVal,
            _tierMapPages
        );

        if (_numCollaborator > 0) {
            /*CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;*/
    /*LibPublishCContentTokenCollaboratorMap
                ._publishCContentTokenCollaboratorMap(
                    _hashId,
                    _numCollaborator,
                    _royaltyVal,
                    _royaltyMap
                );
        }

        // Variant association, parent is index[0] of input array
        AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

        emit CVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
    }*/

    /*
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _baseHashId The Content Token associated to a derivative Variant.
     * @param _hashId Identifier of Content Token being published.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _variantIndex Numerical index correlating to the total Variant count of a Content Token.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    /*function publishCVariantTest(
        address _creatorId,
        bytes32 _baseHashId,
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator,
        uint16 _variantIndex,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();
        if (
            _cContentToken.numToken == 0 ||
            _cContentToken.cSupplyVal == 0 ||
            _variantIndex == 0
        ) revert PublishCContentToken__NumInputInvalid();

        // Storage locals
        /*ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();*/

    /*CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();*/

    /*AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();

        //
        //
        // ***** The below three actions: s_cContentTokenSearch =>
        // _publishCContentTokenSearch, _publishCreatorToken, _publishCContentTokenWavSupplies
        // need to be revamped to work for this function like we did with PublishCContentTokenBatch *****
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

    /*LibPublishCContentTokenSearch._publishCContentTokenSearch(
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

        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSupplies(
            _hashId,
            _cSupplyVal,
            _sSupplyVal,
            _sReserveVal,
            _tierMapPages
        );*/

    /*LibPublishCContentTokenWavSupplies._publishCContentTokenWavSuppliesTest(
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

        /*if (_numCollaborator > 0) {
            /*CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;*/
    /*LibPublishCContentTokenCollaboratorMap
                ._publishCContentTokenCollaboratorMap(
                    _hashId,
                    _numCollaborator,
                    _royaltyVal,
                    _royaltyMap
                );*/

    /*LibPublishCContentTokenCollaboratorMapBatch
                ._publishCContentTokenCollaboratorMapBatch(
                    _hashId,
                    _collaborator
                );*/
    /*}*/

    // Variant association, parent is index[0] of input array
    /*AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

        emit CVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
    }*/

    /**
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCVariant(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (
            _cContentToken.numToken == 0 ||
            _cContentToken.cSupplyVal == 0 ||
            _creatorTokenVariant.variantIndex == 0
        ) {
            revert PublishCContentToken__NumInputInvalid();
        }

        LibPublishCContentTokenWavSupplies
            ._publishCContentTokenVariantWavSupplies(
                _creatorTokenVariant,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );

        LibPublishCContentTokenSearch._publishCContentTokenVariantSearch(
            _creatorTokenVariant,
            _cContentToken,
            _collaborator
        );

        LibPublishVariantHelper._publishVariantHelper(_creatorTokenVariant);

        emit CVariantPublished(
            _creatorTokenVariant.creatorToken.creatorId,
            _creatorTokenVariant.baseHashId,
            _creatorTokenVariant.creatorToken.hashId,
            _creatorTokenVariant.variantIndex
        );
    }
}
