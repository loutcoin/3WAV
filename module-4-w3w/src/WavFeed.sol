// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// '0x97d9F9A00dEE0004BE8ca0A8fa374d486567eE2D' (ETH:USD) (Polygon zkEVM) (8 decimal)

import {AggregatorV3Interface} from "module-4-w3w/lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract WavFeed {
    AggregatorV3Interface internal s_priceFeed;

    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (, int price, , , ) = s_priceFeed.latestRoundData();
        return price;
    }

    /**
     * Converts ETH amount to USD
     */
    function convertEthToUsd(uint256 ethAmount) public view returns (uint256) {
        int price = getLatestPrice();
        // ETH amount is in wei (1 ETH = 10^18 wei)
        // Price is in 8 decimal places, so we need to adjust the conversion
        return (ethAmount * uint256(price)) / 10 ** 8;
    }
}
