// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library ReserveExchangeToken {
    bytes32 constant STORAGE_SLOT = keccak256("Reserve.Exchange.Token.Storage");

    // compaction refactors // ContentToken AutoRelease
    struct ReserveExchange {
        address recipient;
        bytes32 hashId;
        uint16 numToken;
        uint112 purchaseQuantity;
    }

    function reserveExchangeStorage()
        internal
        pure
        returns (ReserveExchange storage ReserveExchangeStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ReserveExchangeStruct.slot := _storageSlot
        } // struct instance
    }
}
