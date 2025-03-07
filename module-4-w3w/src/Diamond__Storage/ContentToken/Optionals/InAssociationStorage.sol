// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library InAssociationStorage {
    bytes32 constant STORAGE_SLOT = keccak256("In.Association.Struct.Storage");

    /**
     * @title InAssociation
     * @notice Stores retroactive pairs of association for music tokens
     */
    struct InAssociation {
        mapping(bytes32 hashId => mapping(uint32 associationIndex => bytes32 associatedHash)) internal s_inAssociation;
    }

    function inAssociationStorage()
        internal
        pure
        returns (InAssociation storage InAssociationStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            InAssociationStruct.slot := _storageSlot
        }
    }


}