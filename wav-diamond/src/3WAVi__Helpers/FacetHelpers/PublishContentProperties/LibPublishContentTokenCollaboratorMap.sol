// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {
    CollaboratorMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";
import {
    CollaboratorStructStorage
} from "../../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

library LibPublishContentTokenCollaboratorMap {
    error PublishContentTokenCollaborator__LengthMismatch();

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
                cRoyaltyVal: _collab.cRoyaltyVal,
                sRoyaltyVal: _collab.sRoyaltyVal,
                royaltyMap: _collab.royaltyMap
            });
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        } else {
            if (_collab.royaltyMap.length == 0)
                revert PublishContentTokenCollaborator__LengthMismatch();
        }
    }
}
