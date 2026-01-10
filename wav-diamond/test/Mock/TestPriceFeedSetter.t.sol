// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    PriceFeedAddrStorage
} from "../../src/Diamond__Storage/ActiveAddresses/PriceFeedAddrStorage.sol";

import {
    AggregatorV3Interface
} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TestPriceFeedSetter {
    function setPriceFeed(address _feed) external {
        PriceFeedAddrStorage.PriceFeedAddrStruct
            storage PriceFeedAddrStructStorage = PriceFeedAddrStorage
                .priceFeedAddrStorage();
        PriceFeedAddrStructStorage.s_priceFeed = AggregatorV3Interface(_feed);
    }
}
