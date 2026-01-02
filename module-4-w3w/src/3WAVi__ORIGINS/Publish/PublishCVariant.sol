// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    LibPublishCContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishCContentTokenWavSupplies.sol";

import {
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishVariantHelper.sol";

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
