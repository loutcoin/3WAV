// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CreatorToken} from "../CreatorTokenStorage.sol";
// 7
// @dev: the struct can likely be optimized

library TokenBalanceStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Creator.Token.Balance.Storage");

    struct TokenBalance {
     mapping(address userId => mapping(bytes32 hashId => uint256 tokenBalance))
        internal s_tokenBalance;
    
   // mapping(bytes32 hashId => uint256 remainderSupply) internal s_remainingSupply;
    
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