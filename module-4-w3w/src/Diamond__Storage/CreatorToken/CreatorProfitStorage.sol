// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 7

library CreatorProfitStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Profit.Struct.Storage");

    struct CreatorProfitStruct {
        mapping(address creatorId => mapping(bytes32 hashId => uint256 ethEarnings)) s_ethEarnings;
        mapping(address wavId => uint256 ethEarnings) s_serviceBalance;
        address wavId;
    }

    // check syntax in next update
    function creatorProfitStorage()
        internal
        pure
        returns (CreatorProfitStruct storage CreatorProfitStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorProfitStructStorage.slot := _storageSlot
        }
    }
}
