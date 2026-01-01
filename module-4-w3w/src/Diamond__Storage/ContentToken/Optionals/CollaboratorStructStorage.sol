// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library CollaboratorStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Collaborator.Struct.Storage");

    /**
     * @title Collaborator
     * @notice Stores collaborator values of Content Tokens
     */
    struct Collaborator {
        uint8 numCollaborator; // number of collaborators across an entire work / hashId non-specific to numToken
        uint32 cRoyaltyVal;
        uint128 sRoyaltyVal;
        uint256[] royaltyMap;
    }

    // should honestly be 'cRoyalty' and 'sRoyaltyMap' to operate using same bit decode/encode as elsewhere in system...

    /* dynamic percentages of 90% creator profit available to collaborators
      Content with more and in-depth collaboration may need larger royalty of 90% available to Collaborators */
    /* uint160 splitVal  pre-defined values Collaborators can claim from their share of the value pool
      Collaborators may collectively challenge splits in a collective effort if deemed unfair by 2/3 majority of collaborators */

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
