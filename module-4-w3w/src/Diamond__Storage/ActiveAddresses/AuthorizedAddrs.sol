// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library AuthorizedAddrs {
    bytes32 constant STORAGE_SLOT = keccak256("Authorized.Addrs.Storage");

    struct AuthorizedAddrMap {
        address s_lout;
        mapping(address => bool) public s_isAuthorizedAddr;
    }

    function authorizedAddrStorage()
        internal
        pure
        returns (AuthorizedAddrMap storage AuthorizedAddrStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            AuthorizedAddrStruct.slot := _storageSlot
        }
    }
}
