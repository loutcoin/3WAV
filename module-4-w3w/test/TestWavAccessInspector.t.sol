// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CreatorTokenStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    TokenBalanceStorage
} from "../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

import {
    CreatorTokenMapStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";

contract TestWavAccessInspector {
    /*function getOwnershipIndex(address _user) external view returns (uint256) {
        return
            CreatorTokenMapStorage.creatorTokenMapStorage().s_ownershipIndex[
                _user
            ];
    }

    function getOwnershipEntry(
        address _user,
        uint256 _idx
    )
        external
        view
        returns (bytes32 _hashId, uint16 _numToken, uint256 _balance)
    {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();
        _hashId = CreatorTokenMapStruct.s_ownershipMap[_user][_idx];
        _numToken = CreatorTokenMapStruct.s_ownershipToken[_user][_idx];
        _balance = TokenBalanceStruct.s_tokenBalance[_user][_hashId][_numToken];
    }

    function getPublishedToken(
        bytes32 _hashId,
        uint16 _numToken
    )
        external
        view
        returns (address _creatorId, uint256 _contentId, bytes32 _hashIdValue)
    {
        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage()
                .s_publishedTokenData[_hashId][_numToken];
        return (
            CreatorTokenStruct.creatorId,
            CreatorTokenStruct.contentId,
            CreatorTokenStruct.hashId
        );
    }*/
}
