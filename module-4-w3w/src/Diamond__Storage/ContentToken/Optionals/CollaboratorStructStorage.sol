// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library CollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Collaborator.Struct.Storage");

    /**
     * @title Collaborator
     * @notice Stores collaborator values of Content Tokens
     */
    struct Collaborator {
        uint8 numCollaborator;
        uint32 cRoyaltyVal;
        uint128 sRoyaltyVal;
        uint256[] royaltyMap;
    }

    function collaboratorStructStorage()
        internal
        pure
        returns (Collaborator storage CollaboratorStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CollaboratorStruct.slot := _storageSlot
        }
    }
}
