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
    LibPublishSContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearchBatch.sol";

import {
    LibPublishSContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSuppliesBatch.sol";
/*import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";*/

contract PublishSContentTokenBatch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken,
        uint32 priceUsdVal,
        uint112 supplyVal,
        uint96 releaseVal
    );

    event SContentTokenBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    error PublishSContentTokenBatch__NumInputInvalid();
    error PublishSContentTokenBatch__LengthMismatch();

    /*
     * @notice Publishes a batch of two or more user-defined SContentTokens.
     * @dev Writes and stores the data of multiple SContentTokens on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     */
    /*function publishSContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (
            _hashIdBatch.length < 2 ||
            _sContentToken.length != _hashIdBatch.length ||
            _collaborator.length != _hashIdBatch.length
        ) revert PublishSContentTokenBatch__LengthMismatch();

        // Storage locals
        /*ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();*/

    //uint112[] memory _supplyValBatch = new uint112[](_hashIdBatch.length);
    //
    // (reminder) input loaded in memory instead of calldata
    /*LibPublishSContentTokenWavSuppliesBatch
            ._publishSContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _supplyValBatch
            );

        LibPublishSContentTokenSearchBatch._publishSContentStackTest(
            _creatorId,
            _hashIdBatch,
            _sContentToken,
            _collaborator
        );

        /*for (uint256 i = 0; i < _hashIdBatch.length; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            // Shared validation ****_supplyVal should not be less than min Encoded****
            if (_numToken == 0 || _sCTKN.supplyVal == 0)
                revert PublishSContentTokenBatch__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
            });

            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    CollaboratorMapStruct.s_collaborators[
                        _hashId
                    ] = CollaboratorStructStorage.Collaborator({
                        numCollaborator: _collab.numCollaborator,
                        royaltyVal: _collab.royaltyVal
                    });
                    CollaboratorMapStruct.s_royalties[
                        _hashId
                    ] = _royaltyMapBatch[i];
                    CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0)
                    revert PublishSContentTokenBatch__LengthMismatch();
            }

            emit SContentTokenPublished(
                _creatorId,
                _hashId,
                _numToken,
                _sCTKN.priceUsdVal,
                _sCTKN.supplyVal,
                _sCTKN.releaseVal
            );

            unchecked {
                ++i;
            }
        }*/

    /*emit SContentTokenBatchPublishedCount(
            _creatorId,
            uint16(_hashIdBatch.length)
        );
    }*/

    /**
     * @notice Publishes a batch of two or more user-defined SContentTokens.
     * @dev Writes and stores the data of multiple SContentTokens on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     */
    function publishSContentTokenBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
    ) external {
        ReturnValidation.returnIsAuthorized();
        LibPublishSContentTokenWavSuppliesBatch
            ._publishSContentTokenWavSuppliesBatch(
                _creatorToken,
                _sContentToken
            );

        LibPublishSContentTokenSearchBatch._publishSContentTokenSearchBatch(
            _creatorToken,
            _sContentToken,
            _collaborator
        );
    }
}
