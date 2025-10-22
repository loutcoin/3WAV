// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library CollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Collaborator.Map.Storage");

    /**
     * @title Collaborator
     * @notice Stores collaborator values of music tokens
     */
    struct CollaboratorMap {
        mapping(bytes32 hashId => Collaborator) s_collaborators;
        mapping(bytes32 hashId => uint256 royaltyMap) s_royalties;
        mapping(bytes32 hashId => mapping(uint16 numToken => uint256 reserve)) s_collaboratorReserve;
        // add royaltyMap for numToken of hashId
        // add address to allow address(collaborator) to join for <x> splitVal
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
