// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library FacetAddrStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Facet.Addr.Storage");

    struct FacetAddrStruct {
        AggregatorV3Interface s_priceFeed;
        address s_wavAccess;
        address s_wavDBC;
        address s_wavFeed;
        address s_wavFortress;
        address s_wavStore;
        address s_wavToken;
        address s_wavZip;
    }

    function facetAddrStorage()
        internal
        pure
        returns (FacetAddrStruct storage FacetAddrStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            FacetAddrStructStorage.slot := _storageSlot
        }
    }
}
