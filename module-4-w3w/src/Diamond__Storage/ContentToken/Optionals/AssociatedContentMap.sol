// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// OG:
// InAssociationStorage.InAssociation storage InAssociationStruct = InAssociationStorage.inAssociationStorage();

// Refactored:
// AssociatedContentMap.AssociatedContent storage AssociatedContentStruct = AssociatedContentMap.associatedContentMap();

library AssociatedContentMap {
    bytes32 constant STORAGE_SLOT =
        keccak256("Associated.Content.Struct.Storage");

    /**
     * @title AssociatedContent
     * @notice Stores retroactive pairs of association for music tokens
     */
    struct AssociatedContent {
        mapping(bytes32 hashId => mapping(uint32 associationIndex => bytes32 associatedHash)) s_inAssociation;
        mapping(bytes32 baseHashId => mapping(uint16 variantIndex => bytes32 variantHashId)) s_variantMap;
        mapping(bytes32 variantHashId => bytes32 baseHashId) s_variantSearch;
    }

    function associatedContentMap()
        internal
        pure
        returns (AssociatedContent storage AssociatedContentStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            AssociatedContentStruct.slot := _storageSlot
        }
    }
}
