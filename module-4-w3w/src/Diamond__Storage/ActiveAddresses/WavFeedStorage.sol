// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library WavFeedStorage {
    bytes32 constant STORAGE_SLOT = keccak256("Wav.Feed.Storage");

    struct WavFeedStruct {
        AggregatorV3Interface internal s_priceFeed;

    }

    function returnWavFeedStorage()
        internal
        pure
        returns (WavFeedStruct storage WavFeedStructStorage)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            WavFeedStructStorage.slot := _storageSlot
        }
    }
}
