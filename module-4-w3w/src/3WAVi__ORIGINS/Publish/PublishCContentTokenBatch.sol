// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    LibPublishCContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSuppliesBatch.sol";

import {
    LibPublishCContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearchBatch.sol";

contract PublishCContentTokenBatch {
    /**
     * @notice Publishes a batch of two or more user-defined CContentTokens.
     * @dev Writes and stores the data of multiple CContentTokens on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCContentTokenBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesBatch(
                _creatorToken,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );
        LibPublishCContentTokenSearchBatch._publishCContentTokenSearchBatch(
            _creatorToken,
            _cContentToken,
            _collaborator
        );
    }
}
