// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library WavResaleToken {
    bytes32 constant STORAGE_SLOT = keccak256("Wav.Resale.Token.Storage");

    // compaction refactors // ContentToken AutoRelease
    struct WavResale {
        address seller;
        address creatorId;
        bytes32 hashId;
        uint16 numToken;
        uint112 purchaseQuantity;
        uint256 priceInEth;
    }

    function wavResaleStorage()
        internal
        pure
        returns (WavResale storage WavResaleTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            WavResaleTokenStruct.slot := _storageSlot
        } // struct instance
    }
}
