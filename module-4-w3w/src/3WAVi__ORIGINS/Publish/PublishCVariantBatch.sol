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
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishVariantHelper.sol";

import {
    LibPublishCContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishCContentTokenWavSuppliesBatch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishCContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCContentTokenSearchBatch.sol";

import {
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCContentTokenSearch.sol";

contract PublishCVariantBatch {
    /**
     * @notice Publishes two or more CContentToken Variants.
     * @dev Writes and stores the data of two or more CContentToken Variants on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        {
            LibPublishCContentTokenSearchBatch
                ._publishCContentTokenVariantSearchBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _collaborator
                );
        }

        for (uint256 i = 0; i < _cContentToken.length; ) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            LibPublishVariantHelper._publishVariantHelper(_cTV);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Publishes a single CContentToken alongside two or more CContentToken Variants.
     * @dev Writes and stores the data of multiple CContentTokens, including one or more CContentToken Variants, on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCContentTokenVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        for (uint256 i = 0; i < _cContentToken.length; i++) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            CollaboratorStructStorage.Collaborator
                calldata _collab = _collaborator[i];

            {
                LibPublishCContentTokenSearch
                    ._publishCContentTokenVariantSearch(_cTV, _cCTKN, _collab);
            }

            if (i > 0) {
                LibPublishVariantHelper._publishVariantHelper(_cTV);
            }
        }
    }
}
