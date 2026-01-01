// SPDX-License-Identifier: MIT
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
    LibPublishSContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSuppliesBatch.sol";

import {
    LibPublishSContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearchBatch.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishVariantHelper.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

contract PublishSVariantBatch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken,
        uint32 priceUsdVal,
        uint112 supplyVal,
        uint96 releaseVal
    );

    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    event SContentTokenBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event SVariantBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    error PublishSVariantBatch__LengthMismatch();
    error PublishSVariantBatch__NumInputInvalid();
    error PublishSVariantBatch__IndexIssue();

    /**
     * @notice Publishes two or more SContentToken Variants.
     * @dev Writes and stores the data of two or more SContentToken Variants on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _sCollaborator Batch of user-defined SCollaborator structs.
     */
    function publishSVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator[] calldata _sCollaborator
    ) external {
        ReturnValidation.returnIsAuthorized();
        {
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _sContentToken
                );
        }
        {
            LibPublishSContentTokenSearchBatch
                ._publishSContentTokenVariantSearchBatch(
                    _creatorTokenVariant,
                    _sContentToken,
                    _sCollaborator
                );
        }

        for (uint256 i = 0; i < _sContentToken.length; i++) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            LibPublishVariantHelper._publishVariantHelper(_cTV);
        }
    }

    /**
     * @notice Publishes a single SContentToken alongside two or more SContentToken Variants.
     * @dev Writes and stores the data of multiple SContentTokens, including one or more SContentToken Variants, on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined _creatorTokenVariants
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _sCollaborator Batch of user-defined SCollaborator structs.
     */
    function publishSContentTokenVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator[] calldata _sCollaborator
    ) external {
        ReturnValidation.returnIsAuthorized();
        {
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _sContentToken
                );
        }
        for (uint256 i = 0; i < _sContentToken.length; i++) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];

            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            SCollaboratorStructStorage.SCollaborator
                calldata _sCollab = _sCollaborator[i];

            LibPublishSContentTokenSearch._publishSContentTokenVariantSearch(
                _cTV,
                _sCTKN,
                _sCollab
            );
            if (i > 0) {
                LibPublishVariantHelper._publishVariantHelper(_cTV);
            }
        }
    }
}
