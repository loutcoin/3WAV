// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* '0x97d9F9A00dEE0004BE8ca0A8fa374d486567eE2D' (ETH:USD) (Polygon zkEVM) (8 decimal)
Preforms gasless live price calculations, uses data to pass along function calls
*/

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract WavFeed {
    AggregatorV3Interface internal s_priceFeed;

    constructor(address _priceFeed) {
        s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Returns the latest price
     * @return int256 The latest price
     */
    function getLatestPrice() public view returns (int256) {
        (, int256 price, , , ) = s_priceFeed.latestRoundData();
        return price;
    }

    /**
     * @notice Converts ETH amount to USD
     * @param ethAmount The amount of ETH in wei
     * @return uint256 The equivalent amount in USD
     */
    function convertEthToUsd(uint256 ethAmount) public view returns (uint256) {
        int256 price = getLatestPrice();
        // ETH amount is in wei (1 ETH = 10^18 wei)
        // Price is in 8 decimal places, so we need to adjust the conversion
        return (ethAmount * uint256(price)) / 10 ** 8;
    }

    /**
     * @notice Converts USD amount to ETH
     * @param usdAmount The amount of USD in 8 decimal places
     * @return uint256 The equivalent amount in ETH
     */
    function convertUsdToEth(uint256 usdAmount) public view returns (uint256) {
        int256 price = getLatestPrice();
        // USD amount is in 8 decimal places
        // Price is in 8 decimal places, so we need to adjust the conversion
        return (usdAmount * 10 ** 8) / uint256(price);
    }
}
