// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {CreatorTokenStorage} from "../CreatorToken/CreatorTokenStorage.sol";

library CreatorTokenMapStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Map.Storage");

    struct CreatorTokenMap {
        // Efficiently allows for access and storage with the creator token struct
        mapping(bytes32 hashId => CreatorTokenStorage.CreatorToken) s_publishedTokenData;
        // Tracks current 'content index' of user
        mapping(address userId => uint256 indexCount) s_ownershipIndex;
        // Maps user wallet address to ordered count of owned hashId's;
        mapping(address userId => mapping(uint256 contentIndex => bytes32 hashId)) s_ownershipMap;
        // Maps user wallet address to ordered count of owned numToken's
        mapping(address userId => mapping(uint256 contentIndex => uint16 numToken)) s_ownershipToken;
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
