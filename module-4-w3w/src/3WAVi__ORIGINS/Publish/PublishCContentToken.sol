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
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCContentTokenSearch.sol";

import {
    LibPublishCContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishCContentTokenWavSupplies.sol";

contract PublishCContentToken {
    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

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

        // Publishes supply data
        LibPublishCContentTokenWavSupplies._publishCContentTokenWavSupplies(
            _creatorToken,
            _cContentToken,
            _tierMapPages,
            _priceMapPages
        );

        // Publishes CContentToken properties
        LibPublishCContentTokenSearch._publishCContentTokenSearch(
            _creatorToken,
            _cContentToken,
            _collaborator
        );

        emit CContentTokenPublished(
            _creatorToken.creatorId,
            _creatorToken.hashId,
            _cContentToken.numToken
        );
    }
}
