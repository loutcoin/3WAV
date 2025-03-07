// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library CollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Collaborator.Struct.Storage");

    /**
     * @title Collaborator
     * @notice Stores collaborator values of Content Tokens
     */
    struct Collaborator {
        uint176 splitShareMap; // up to 26 2-bit collaborators can be compensated
        uint80; splitVal; // <xx.xx%_xx> (max 4x) 4-digit percentage splits appended with 2 digit bit_id
        address[] collaboratorVal;
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