// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    LibPublishSContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearchBatch.sol";

import {
    LibPublishSContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishSContentTokenWavSuppliesBatch.sol";

contract PublishSContentTokenBatch {
    event SContentTokenBatchPublishedCount(uint256 indexed publicationCount);

    /**
     * @notice Publishes a batch of two or more user-defined SContentTokens.
     * @dev Writes and stores the data of multiple SContentTokens on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _sCollaborator Batch of user-defined SCollaborator structs.
     */
    function publishSContentTokenBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator[] calldata _sCollaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        // Publishes supply data
        LibPublishSContentTokenWavSuppliesBatch
            ._publishSContentTokenWavSuppliesBatch(
                _creatorToken,
                _sContentToken
            );

        {
            // Publishes SContentToken properties, emits event for individual indexes
            LibPublishSContentTokenSearchBatch._publishSContentTokenSearchBatch(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }

        emit SContentTokenBatchPublishedCount(_sContentToken.length);
    }
}
