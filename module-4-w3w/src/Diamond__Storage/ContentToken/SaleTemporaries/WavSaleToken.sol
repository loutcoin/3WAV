// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library WavSaleToken {
    bytes32 constant STORAGE_SLOT = keccak256("Wav.Sale.Token.Storage");

    // compaction refactors // ContentToken AutoRelease
    struct WavSale {
        address creatorId;
        bytes32 hashId;
        uint16 numToken;
        uint112 purchaseQuantity;
    }

    function wavSaleStorage()
        internal
        pure
        returns (WavSale storage WavSaleTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            WavSaleTokenStruct.slot := _storageSlot
        } // struct instance
    }
}
