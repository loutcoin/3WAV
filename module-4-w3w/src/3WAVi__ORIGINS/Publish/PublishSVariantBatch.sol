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
    LibPublishSContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishSContentTokenWavSuppliesBatch.sol";

import {
    LibPublishSContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearchBatch.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishVariantHelper.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

contract PublishSVariantBatch {
    event SVariantBatchPublishedCount(uint256 indexed publicationCount);

    event SContentTokenVariantBatch(
        address indexed _creatorId,
        bytes32 indexed _hashId,
        uint16 indexed _numToken
    );

    event SContentTokenVariantBatchPublishedCount(
        uint256 indexed publicationCount
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
            // Publishes supply data
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _sContentToken
                );
        }
        {
            // Publishes SContentToken properties, emits event for individual indexes
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
        emit SVariantBatchPublishedCount(_sContentToken.length);
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
            // Publishes supply data
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

            // Publishes index-specific SContentToken properties
            LibPublishSContentTokenSearch._publishSContentTokenVariantSearch(
                _cTV,
                _sCTKN,
                _sCollab
            );

            if (i > 0) {
                // Publishes index-specific Variant data
                LibPublishVariantHelper._publishVariantHelper(_cTV);
            }

            emit SContentTokenVariantBatch(
                _cTV.creatorToken.creatorId,
                _cTV.creatorToken.hashId,
                _sCTKN.numToken
            );
        }
        emit SContentTokenVariantBatchPublishedCount(_sContentToken.length);
    }
}
