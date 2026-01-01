// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SCollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("SCollaborator.Struct.Storage");

    /**
     * @title SCollaborator
     * @notice Stores collaborator values of SContent Tokens
     */
    struct SCollaborator {
        uint8 numCollaborator;
        uint32 cRoyaltyVal;
    }
    //uint256 royaltyMap;

    function sCollaboratorStructStorage()
        internal
        pure
        returns (SCollaborator storage SCollaboratorStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            SCollaboratorStruct.slot := _storageSlot
        }
    }
}
