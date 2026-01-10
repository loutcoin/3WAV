// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {CContentTokenStorage} from "../ContentToken/CContentTokenStorage.sol";

library ContentTokenSupplyMapStorage {
    bytes32 constant STORAGE_SLOT =
        keccak256("Content.Token.Supply.Map.Storage");

    struct ContentTokenSupplyMap {
        mapping(bytes32 hashId => uint112 wavSupplies) s_cWavSupplies;
        mapping(bytes32 hashId => mapping(uint16 tierId => uint112 sTierSupplies)) s_sWavSupplies;
        //mapping(bytes32 hashId => mapping(uint16 tierId => mapping(uint16 reserveIndex => uint256 reserveSupply))) theoretical WR sub-supply system
        mapping(bytes32 hashId => mapping(uint16 batchCounter => uint256 tierMap)) s_tierMap;
        mapping(bytes32 hashId => mapping(uint16 batchCounter => uint256 priceMap)) s_sPriceMap;
    }

    function contentTokenSupplyMapStorage()
        internal
        pure
        returns (ContentTokenSupplyMap storage ContentTokenSupplyMapStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            ContentTokenSupplyMapStruct.slot := _storageSlot
        }
    }
}
