// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
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
/*import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";*/
import {
    LibPublishSContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSupplies.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishVariantHelper.sol";

contract PublishSVariant {
    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    error PublishSContentToken__NumInputInvalid();

    //* @notice Publishes a single user-defined SContentToken.
    //* @dev Writes and stores the data of a SContentToken on the blockchain.
    //* @param _creatorId The address of the creator.
    //* @param _hashId Identifier of Content Token being published.
    //* @param _numToken Token index quantity of the Content Token.
    //* @param _priceUsdVal Unsigned interger containing Content Token price definition.
    //* @param _supplyVal Unsigned interger containing Content Token supply data
    //* @param _releaseVal Unsigned interger containing timestamp publication data.
    //* @param _variantIndex Numerical index correlating to the total Variant count of a Content Token.
    //* @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
    //* @param _royaltyVal Unsigned interger containing collaborator royalty data.
    //* @param _royaltyMap Royalty state map of the Content Token numToken index values.
    /*function publishSVariant(
        address _creatorId,
        bytes32 _baseHashId,
        bytes32 _hashId,
        uint16 _numToken,
        uint32 _priceUsdVal,
        uint112 _supplyVal,
        uint96 _releaseVal,
        uint16 _variantIndex,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_numToken == 0 || _supplyVal == 0 || _variantIndex == 0) {
            revert PublishSContentToken__NumInputInvalid();
        }
        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();

        ContentTokenSearchStruct.s_sContentTokenSearch[
            _hashId
        ] = SContentTokenStorage.SContentToken({
            numToken: _numToken,
            priceUsdVal: _priceUsdVal,
            supplyVal: _supplyVal,
            releaseVal: _releaseVal
        });

        LibPublishCreatorToken._publishCreatorToken(
            _creatorId,
            _hashId,
            _numToken
        );

        LibPublishSContentTokenWavSupplies._publishSContentTokenWavSupplies(
            _hashId,
            _supplyVal
        );

        if (_numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        }
        // Variant association, parent is index[0] of input array
        AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

        emit SVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
    }*/

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorTokenVariant User-defined CreatorTokenVariant struct
     * @param _sContentToken User-defined SContentToken struct
     * @param _collaborator User-defined Collaborator struct
     */
    function publishSVariant(
        //address _creatorId,
        //bytes32 _baseHashId,
        //bytes32 _hashId,
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
        //uint16 _variantIndex
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (
            _sContentToken.numToken == 0 ||
            _sContentToken.supplyVal == 0 ||
            _creatorTokenVariant.variantIndex == 0
        ) {
            revert PublishSContentToken__NumInputInvalid();
        }

        /*LibPublishSContentTokenWavSupplies._publishSContentTokenWavSupplies(
            _hashId,
            _sContentToken.cSupplyVal
        );*/

        LibPublishSContentTokenWavSupplies
            ._publishSContentTokenVariantWavSupplies(
                _creatorTokenVariant,
                _sContentToken
            );

        /*LibPublishSContentTokenSearch._publishSContentTokenSearchTest(
            _creatorId,
            _hashId,
            _sContentToken,
            _collaborator
        );*/
        LibPublishSContentTokenSearch._publishSContentTokenVariantSearch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        /*AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;*/

        LibPublishVariantHelper._publishVariantHelper(_creatorTokenVariant);

        emit SVariantPublished(
            _creatorTokenVariant.creatorToken.creatorId,
            _creatorTokenVariant.baseHashId,
            _creatorTokenVariant.creatorToken.hashId,
            _creatorTokenVariant.variantIndex
        );
    }
}
