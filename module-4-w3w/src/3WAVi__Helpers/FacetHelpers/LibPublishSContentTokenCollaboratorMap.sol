// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";
import {
    SCollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

library LibPublishSContentTokenCollaboratorMap {
    function _publishSContentTokenCollaboratorMap(
        bytes32 _hashId,
        SCollaboratorStructStorage.SCollaborator calldata _sCollaborator
    ) internal {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        CollaboratorMapStruct.s_sCollaborators[
            _hashId
        ] = SCollaboratorStructStorage.SCollaborator({
            numCollaborator: _sCollaborator.numCollaborator,
            royaltyVal: _sCollaborator.royaltyVal,
            royaltyMap: _sCollaborator.royaltyMap
        });
        CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
    }
}
