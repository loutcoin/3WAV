// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library SContentTokenStorage {
    bytes32 constant STORAGE_SLOT = keccak256("SContent.Token.Struct.Storage");

    struct SContentToken {
        // *SLOT 1*
        uint16 numToken;
        uint32 priceUsdVal; // 0B primary_priceInUsd
        uint112 supplyVal; // 0B *initial*totalSupply[0], | 2B wav*Pre*Reserve[2]
        uint96 releaseVal; // 0B standard/Start, | 2B end[2] | 3B preStart*pauseAt*[3]
    }

    function sContentTokenStructStorage()
        internal
        pure
        returns (SContentToken storage SContentTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            SContentTokenStruct.slot := _storageSlot
        }
    }
}
