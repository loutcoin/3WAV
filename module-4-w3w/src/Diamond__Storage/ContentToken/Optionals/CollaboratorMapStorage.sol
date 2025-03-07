// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library CollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Collaborator.Map.Storage");

    /**
     * @title Collaborator
     * @notice Stores collaborator values of music tokens
     */
    struct CollaboratorMap {
        mapping(bytes32 _hashId => Collaborator) s_collaborators;
    }

    function collaboratorMapStorage()
        internal
        pure
        returns (CollaboratorMap storage CollaboratorMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CollaboratorMapStruct.slot := _storageSlot
        }
    }
}
