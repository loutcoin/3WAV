// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 1

library CreatorAliasMapStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Alias.Map.Storage");

    struct CreatorAlias {
        ///@notice Stores information regarding availability of an alias.
        mapping(string => address) s_aliasToAddr;
        mapping(address => string) s_addrToAlias;
    }

    function creatorAliasStructStorage()
        internal
        pure
        returns (CreatorAlias storage CreatorAliasMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorAliasMapStruct.slot := _storageSlot
        }
    }
}
