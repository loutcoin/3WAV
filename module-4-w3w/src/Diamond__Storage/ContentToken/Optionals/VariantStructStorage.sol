// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// DEPRECATED (Functionality consolidated into existing infastructure without need of dedicated 'Variants' struct) *

library VariantStructStorage {
    /*  bytes32 constant STORAGE_SLOT = keccak256("Variant.Token.Struct.Storage");

    /**
     * @title Variants
     * @notice Stores information about different variants of a music token.
     * @dev Defines numerical index, total audio content, and variant-specific supply.
     */
    /*   struct Variants {
        /// @notice Numerical index batch of Variant in relation to publish context.
        uint8 numVariant; // was uint24
        /// @notice Number of variant-specific audio tracks. If token is not collection, numVariantAudio always == 1.
        uint16 numVariantToken; // was uint24
        /// @notice Raw numerical value (USD, Rarity, etc;) associated with obtaining the Variant.
        uint32 rVal;
        /// @notice Total supply of specific variant derivative.
        uint112 variantSupply; // *initial*totalSupply[0], | 2B wav*Pre*Reserve[2] // was uint104
        uint96 releaseVal;
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
    } */
}
