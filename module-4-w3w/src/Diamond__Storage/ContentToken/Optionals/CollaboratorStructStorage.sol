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
        uint128 royaltyVal;
        /* dynamic percentages of 90% creator profit available to collaborators
      Content with more and in-depth collaboration may need larger royalty of 90% available to Collaborators */
       
       


       
       /* uint160 splitVal  pre-defined values Collaborators can claim from their share of the value pool
        Collaborators may collectively challenge splits in a collective effort if deemed unfair by 2/3 majority of collaborators */;
    }

    /* WHAT IF, struct Collaborator didn't store any addresses...
    WHAT IF, it just stored 'numCollaborators' and instance-specific value splits
    THEN...in a mapping actual collaborators could themselves execute to acknowledge their on-chain involvement
    and request one of the possible defined splits which would then be agreed upon in a multi-sig ma

    */

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

    /*  OLD: uint176 splitShareMap; // up to 26 2-bit collaborators can be compensated
        uint80; splitVal; // <xx.xx%_xx> (max 4x) 4-digit percentage splits appended with 2 digit bit_id
        address[] collaboratorVal; */
}
