// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    FacetAddrStorage
} from "../../src/Diamond__Storage/ActiveAddresses/FacetAddrStorage.sol";

import {
    AggregatorV3Interface
} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TestPriceFeedSetter {
    function setPriceFeed(address _feed) external {
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_priceFeed = AggregatorV3Interface(_feed);
    }
}
