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
    LibPublishSContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishSContentTokenWavSupplies.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearch.sol";

contract PublishSContentToken {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken,
        uint32 priceUsdVal,
        uint112 supplyVal,
        uint96 releaseVal
    );

    error PublishSContentToken__NumInputInvalid();

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _sCollaborator Batch of user-defined SCollaborator structs.
     */
    function publishSContentToken(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator calldata _sCollaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        LibPublishSContentTokenWavSupplies._publishSContentTokenWavSupplies(
            _creatorToken,
            _sContentToken
        );

        LibPublishSContentTokenSearch._publishSContentTokenSearch(
            _creatorToken,
            _sContentToken,
            _sCollaborator
        );
    }
}
