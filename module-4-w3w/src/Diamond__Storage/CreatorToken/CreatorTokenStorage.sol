// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 1

library CreatorTokenStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Struct.Storage");

    struct CreatorToken {
        address creatorId;
        uint256 contentId;
        bytes32 hashId;
    }

    function creatorTokenStructStorage()
        internal
        pure
        returns (CreatorToken storage CreatorTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorTokenStruct.slot := _storageSlot
        }
    }
}
