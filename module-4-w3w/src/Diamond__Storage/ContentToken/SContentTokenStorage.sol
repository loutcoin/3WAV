// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//2
library SContentTokenStorage {
    bytes32 constant STORAGE_SLOT = keccak256("SContent.Token.Struct.Storage");

    // compaction refactors // ContentToken AutoRelease
    struct SContentToken {
        // *SLOT 1*
        uint24 numToken;
        uint32 priceUsdVal; // 0B primary_priceInUsd
        uint104 supplyVal; // 0B *initial*totalSupply[0], | 2B wav*Pre*Reserve[2]
        uint96 releaseVal; // 0B standard/Start, | 2B end[2] | 3B preStart*pauseAt*[3]
        // *SLOT 2*
        uint256 bitVal;
    } // max uint256 ~75 digits

    function sContentTokenStructStorage()
        internal
        pure
        returns (SContentToken storage SContentTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            SContentTokenStruct.slot := _storageSlot
        } // struct instance
    }
}
