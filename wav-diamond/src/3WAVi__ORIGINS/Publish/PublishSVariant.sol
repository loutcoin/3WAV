// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    LibPublishSContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishSContentTokenWavSupplies.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishVariantHelper.sol";

contract PublishSVariant {
    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed variantHashId,
        bytes32 indexed parentHashId,
        uint16 variantIndex
    );

    error PublishSContentToken__NumInputInvalid();

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorTokenVariant User-defined CreatorTokenVariant struct
     * @param _sContentToken User-defined SContentToken struct
     * @param _sCollaborator User-defined SCollaborator struct
     */
    function publishSVariant(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator calldata _sCollaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (
            _sContentToken.numToken == 0 ||
            _sContentToken.supplyVal == 0 ||
            _creatorTokenVariant.variantIndex == 0
        ) {
            revert PublishSContentToken__NumInputInvalid();
        }

        // Publishes supply data
        LibPublishSContentTokenWavSupplies
            ._publishSContentTokenVariantWavSupplies(
                _creatorTokenVariant,
                _sContentToken
            );

        // Publishes SContentToken properties
        LibPublishSContentTokenSearch._publishSContentTokenVariantSearch(
            _creatorTokenVariant,
            _sContentToken,
            _sCollaborator
        );

        // Publishes Variant data
        LibPublishVariantHelper._publishVariantHelper(_creatorTokenVariant);

        emit SVariantPublished(
            _creatorTokenVariant.creatorToken.creatorId,
            _creatorTokenVariant.creatorToken.hashId,
            _creatorTokenVariant.baseHashId,
            _creatorTokenVariant.variantIndex
        );
    }
}
