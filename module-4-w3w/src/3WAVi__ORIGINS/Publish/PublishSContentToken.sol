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
import {
    LibPublishSContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSupplies.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearch.sol";

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
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _priceUsdVal Unsigned interger containing Content Token price definition.
     * @param _supplyVal Unsigned interger containing Content Token supply data
     * @param _releaseVal Unsigned interger containing timestamp publication data.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     */
    /*function publishSContentToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint32 _priceUsdVal,
        uint112 _supplyVal,
        uint96 _releaseVal,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) external {
        ReturnValidation.returnIsAuthorized();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        if (_numToken == 0 || _supplyVal == 0) {
            revert PublishSContentToken__NumInputInvalid();
        }

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

        // Emit Event
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _numToken,
            _priceUsdVal,
            _supplyVal,
            _releaseVal
        );
    }*/

    /*
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     */
    /*unction _publishSContentTokenTest(
        address _creatorId,
        bytes32 _hashId,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_sContentToken.numToken == 0 || _sContentToken.supplyVal == 0) {
            revert PublishSContentToken__NumInputInvalid();
        }

        LibPublishSContentTokenWavSupplies._publishSContentTokenWavSupplies(
            _hashId,
            _sContentToken.cSupplyVal
        );

        LibPublishSContentTokenSearch._publishSContentTokenSearchTest(
            _creatorId,
            _hashId,
            _sContentToken,
            _collaborator
        );

        // Emit Event
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _numToken,
            _priceUsdVal,
            _supplyVal,
            _releaseVal
        );
    }*/

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     */
    function publishSContentToken(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        LibPublishSContentTokenWavSupplies._publishSContentTokenWavSupplies(
            _creatorToken,
            _sContentToken
        );

        LibPublishSContentTokenSearch._publishSContentTokenSearch(
            _creatorToken,
            _sContentToken,
            _collaborator
        );
    }
}
