// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 4

library VariantStructStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Variant.Token.Struct.Storage");

    /**
     * @title Variants
     * @notice Stores information about different variants of a music token.
     * @dev Defines numerical index, total audio content, and variant-specific supply.
     */
    struct Variants {
        /// @notice Numerical index batch of Variant in relation to publish context.
        uint24 numVariant;
        /// @notice Number of variant-specific audio tracks. If token is not collection, numVariantAudio always == 1.
        uint24 numVariantToken;
        /// @notice Total supply of specific variant derivative.
        uint104 variantSupply; // *initial*totalSupply[0], | 2B wav*Pre*Reserve[2]
        /// @notice Raw numerical value (USD, Rarity, etc;) associated with obtaining the Variant.
        uint256 rVal;
    }

    function variantStructStorage()
        internal
        pure
        returns (Variants storage VariantStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            VariantStruct.slot := _storageSlot
        }
    }
}
