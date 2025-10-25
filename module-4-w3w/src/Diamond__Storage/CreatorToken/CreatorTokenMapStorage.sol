// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CreatorTokenStorage} from "../CreatorToken/CreatorTokenStorage.sol";
// 6
// @dev: the struct can likely be optimized

library CreatorTokenMapStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Map.Storage");

    struct CreatorTokenMap {
        // Efficiently allows for access and storage with the creator token struct
        // bytes 1st key pair related to content
        mapping(bytes32 hashId => mapping(uint16 numToken => CreatorTokenStorage.CreatorToken)) s_publishedTokenData;
        //related to ownership states of user
        // Tracks current 'content index' of user
        mapping(address userId => uint256 indexCount) s_ownershipIndex;
        // Maps user wallet address to ordered count for each peice of music they own;
        // represented by music struct.
        mapping(address userId => mapping(uint256 contentIndex => mapping(bytes32 hashId => uint16 _numToken))) s_ownershipMap; // possibly used for OwnerReward tracking?????
    }

    function creatorTokenMapStorage()
        internal
        pure
        returns (CreatorTokenMap storage CreatorTokenMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CreatorTokenMapStruct.slot := _storageSlot
        }
    }
}
