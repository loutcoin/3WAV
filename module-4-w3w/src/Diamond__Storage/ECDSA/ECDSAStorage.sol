// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library ECDSAStorage {
    bytes32 constant STORAGE_SLOT = keccak256("ECDSA.Map.Storage");

    struct ECDSAMap {
        mapping(uint256 => bool) s_nonceCheck;
        mapping(address => uint256) s_userNonce;
    }

    function returnECDSAStorage()
        internal
        pure
        returns (ECDSAMap storage ECDSAMapStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ECDSAMapStorage.slot := _storageSlot
        }
    }
}
