// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";
import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

library LibPublishContentTokenCollaboratorMap {
    error PublishContentTokenCollaborator__LengthMismatch();
    /*function _publishCContentTokenCollaboratorMapBatch(
        bytes32 _hashId,
        CollaboratorStructStorage.Collaborator calldata _collaborator,
        uint256 _royaltyMap
    ) internal {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();
        CollaboratorStructStorage.Collaborator calldata _collab = _collaborator;

        if (_collab.numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _collab.numCollaborator,
                royaltyVal: _collab.royaltyVal
            });
            //CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        } else {
            if (_royaltyMap != 0)
                revert PublishCContentTokenCollaboratorBatch__LengthMismatch();
        }
    }*/

    // this should probably be re-purposed for the singular versions, which
    // should be re-purposed to input struct-types instead of individual properties, this
    // "batch" function should likely contain simple for loop and just upload full batch of
    // Collaborator struct / hashId's.
    // THIS is to avoid reading from the same storage slots several times
    function _publishContentTokenCollaboratorMap(
        bytes32 _hashId,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) internal {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();
        CollaboratorStructStorage.Collaborator calldata _collab = _collaborator;

        if (_collab.numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _collab.numCollaborator,
                royaltyVal: _collab.royaltyVal,
                royaltyMap: _collab.royaltyMap
            });
            //CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        } else {
            // was >
            if (_collab.royaltyMap.length == 0)
                revert PublishContentTokenCollaborator__LengthMismatch();
        }
    }
}
