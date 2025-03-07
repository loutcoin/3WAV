// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CContentToken} from "../ContentToken/CContentTokenStorage.sol";
import {SContentToken} from "../ContentToken/SContentTokenStorage.sol";
//3
library ContentTokenSearchStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Content.Token.Search.Storage");

    struct ContentTokenSearch {
        mapping(bytes32 hashId => CContentToken) internal s_cContentTokenSearch;
        mapping(bytes32 hashId => SContentToken) internal s_sContentTokenSearch;
    }

    function contentTokenSearchStorage()
        internal
        pure
        returns (ContentTokenSearch storage ContentTokenSearchStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ContentTokenSearchStruct.slot := _storageSlot
        }
    }
}
