// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//3
library CContentTokenStorage {
    bytes32 constant STORAGE_SLOT = keccak256("CContent.Token.Struct.Storage");

    struct CContentToken {
        // *SLOT 1*
        uint16 numToken;
        uint112 cSupplyVal; // cTotalSupply, cInitialSupply, cWavR, cPreSaleR
        uint112 sPriceUsdVal; // standard_indv[10], | 2B accessible_indv[01], exclusive_indv[11]
        // *SLOT 2*
        uint32 cPriceUsdVal;
        uint224 sSupplyVal;
        //uint112 sTotalSupply;
        //uint112 sInitialSupply;
        // *SLOT 3*\
        uint160 sReserveVal;
        //uint80 sWavR;
        //uint80 sPreSaleR;
        uint96 cReleaseVal;
        // *SLOT 4*
        uint256 bitVal;
    }

    function cContentTokenStructStorage()
        internal
        pure
        returns (CContentToken storage CContentTokenStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            CContentTokenStruct.slot := _storageSlot
        }
    }
}
