// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import {CreatorTokenStorage} from "../CreatorToken/CreatorTokenStorage.sol";

library TokenBalanceStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Balance.Storage");

    struct TokenBalance {
        mapping(address userId => mapping(bytes32 hashId => mapping(uint16 numToken => uint256 tokenBalance))) s_tokenBalance;
    }

    function tokenBalanceStorage()
        internal
        pure
        returns (TokenBalance storage TokenBalanceStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            TokenBalanceStruct.slot := _storageSlot
        }
    }
}
