// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library AuthorizedAddrStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Authorized.Addr.Storage");

    struct AuthorizedAddrStruct {
        mapping(address => bool) s_authorizedAddrMap;
        mapping(uint256 => address) s_authorizedAddrSearch;
    }

    function authorizedAddrStorage()
        internal
        pure
        returns (AuthorizedAddrStruct storage AuthorizedAddrStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            AuthorizedAddrStructStorage.slot := _storageSlot
        }
    }
}
