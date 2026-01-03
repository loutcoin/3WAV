// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    AggregatorV3Interface
} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceFeedAddrStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Price.Feed.Addr.Storage");

    struct PriceFeedAddrStruct {
        AggregatorV3Interface s_priceFeed;
    }

    function priceFeedAddrStorage()
        internal
        pure
        returns (PriceFeedAddrStruct storage PriceFeedAddrStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            PriceFeedAddrStructStorage.slot := _storageSlot
        }
    }
}
