// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Variants} from "../VariantStructStorage.sol";

// * POSSIBLY DEPRECATED (Functionality consolidated into InAssociation) *

library VariantMapStorage {
    /*  bytes32 constant STORAGE_SLOT = keccak256("Variant.Map.Struct.Storage");

    /**
     * @title VariantMap
     * @notice Stores information about different variants of a music token.
     * @dev Defines numerical index, total audio content, and variant-specific supply.
     */
    /*  struct VariantMap {
        mapping(bytes32 hashId => uint256 rMap) s_variantMap;
        mapping(bytes32 hashId => Variants) s_variantSearch;
    }

    function variantMapStorage()
        internal
        pure
        returns (VariantMap storage VariantMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            VariantMapStruct.slot := _storageSlot
        }
    } */
}
