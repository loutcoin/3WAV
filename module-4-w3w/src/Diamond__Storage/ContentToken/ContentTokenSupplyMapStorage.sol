// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CContentToken} from "../ContentToken/CContentTokenStorage.sol";
//3
library ContentTokenSupplyMapStorage {
    bytes32 constant STORAGE_SLOT =
        keccak256("Content.Token.Supply.Map.Storage");

    struct ContentTokenSupplyMap {
        mapping(bytes32 hashId => uint112 wavSupplies) s_cWavSupplies;
        mapping(bytes32 hashId => mapping(uint16 tierId => uint112 sTierSupplies)) s_sWavSupplies;
        mapping(bytes32 hashId => mapping(uint16 batchCounter => uint256 tierMap)) s_tierMap;
        // mapping(bytes32 hashId => uint256 stateMap) s_enableBitmap;
        // -- (temproarily deprecated for pragmatic reasons, can be reintroduced with optimizations) --
    }

    function contentTokenSupplyMapStorage()
        internal
        pure
        returns (ContentTokenPriceMap storage ContentTokenSupplyMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ContentTokenSupplyMapStruct.slot := _storageSlot
        }
    }
}
