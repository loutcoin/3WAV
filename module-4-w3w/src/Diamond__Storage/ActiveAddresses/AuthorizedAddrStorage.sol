// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library AuthorizedAddrStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Authorized.Addr.Storage");

    struct AuthorizedAddrStruct {
        address s_3Wav;
        address s_lout;
    }

    function authorizedAddrStorage()
        internal
        pure
        returns (AuthorizedAddrStruct storage AuthorizedAddrStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            AuthorizedAddrStruct.slot := _storageSlot
        }
    }
}
