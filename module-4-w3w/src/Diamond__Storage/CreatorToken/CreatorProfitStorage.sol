// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 7
// @dev: the struct can likely be optimized

library CreatorProfitStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Profit.Storage");

    struct CreatorProfitMap {
        mapping(address creatorId => mapping(bytes32 hashId => uint256 ethEarnings)) internal s_ethEarnings;
        mapping(address creatorId => mapping(bytes32 hashId => uint256 loutEarnings)) internal s_loutEarnings;
    
    }

    function creatorProfitMapStructStorage()
        internal
        pure
        returns (CreatorProfitMap storage CreatorProfitMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorProfitMapStruct.slot := _storageSlot
        }
    }
}