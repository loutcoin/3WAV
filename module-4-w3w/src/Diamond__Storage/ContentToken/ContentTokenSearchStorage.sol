// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {CContentTokenStorage} from "../ContentToken/CContentTokenStorage.sol";
import {SContentTokenStorage} from "../ContentToken/SContentTokenStorage.sol";

library ContentTokenSearchStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Content.Token.Search.Storage");

    struct ContentTokenSearch {
        mapping(bytes32 hashId => CContentTokenStorage.CContentToken) s_cContentTokenSearch;
        mapping(bytes32 hashId => SContentTokenStorage.SContentToken) s_sContentTokenSearch;
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
