// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library CreatorProfitStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Profit.Struct.Storage");

    struct CreatorProfitStruct {
        mapping(address creatorId => mapping(bytes32 hashId => uint256 ethEarnings)) s_ethEarnings;
        mapping(address wavId => uint256 ethEarnings) s_serviceBalance;
        address wavId;
    }

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
