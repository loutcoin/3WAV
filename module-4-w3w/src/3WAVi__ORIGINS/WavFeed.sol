// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* '0x97d9F9A00dEE0004BE8ca0A8fa374d486567eE2D' (ETH:USD) (Polygon zkEVM) (8 decimal)
Preforms gasless live price calculations, uses data to pass along function calls
*/

import {WavFeedStorage} "../src/Diamond__Storage/ActiveAddresses/WavFeedStorage.sol";


contract WavFeed {
    /**
     * @notice Returns the current active price feed address.
     * @dev Function Selector: 0x724e78da
     * @param _priceFeed value being defined as the new active address.
     */
    function setPriceFeed(address _priceFeed) external {
        if(_priceFeed = address(0)) revert;
        WavFeedStorage.WavFeedStruct storage WavFeedStructStorage = WavFeedStorage.returnWavFeedStorage();
        WavFeedStructStorage.s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Returns the current active price feed address.
     * @dev Function Selector: 0xa4dfcacd
     * @return address The address value of the active price feed.
     */
    function returnPriceFeedAddress() external view returns(address) {
        WavFeedStorage.WavFeedStruct storage WavFeedStructStorage = WavFeedStorage.returnWavFeedStorage();
        return address(WavFeedStructStorage.s_priceFeed);
    }


    /**
     * @notice Returns the latest price
     * @dev Function Selector: 0x8e15f473
     * @return int256 The latest price
     */
    function getLatestPrice() external view returns (int256) {
        WavFeedStorage.WavFeedStruct storage WavFeedStructStorage = WavFeedStorage.returnWavFeedStorage();
        (, int256 price, , , ) = WavFeedStructStorage.s_priceFeed.latestRoundData();
        return price;
    }

    /**
     * @notice Converts ETH amount to USD
     * @dev Function Selector: 0xc086381e
     * @param ethAmount The amount of ETH in wei
     * @return uint256 The equivalent amount in USD
     */
    function convertEthToUsd(uint256 ethAmount) external view returns (uint256) {
        int256 price = getLatestPrice();
        // ETH amount is in wei (1 ETH = 10^18 wei)
        // Price is in 8 decimal places, so we need to adjust the conversion
        return (ethAmount * uint256(price)) / 10 ** 8;
    }

    /**
     * @notice Converts USD amount to ETH
     * @dev Function Selector: 0xa3053e2a
     * @param usdAmount The amount of USD in 8 decimal places
     * @return uint256 The equivalent amount in ETH
     */
    function convertUsdToEth(uint256 usdAmount) public view returns (uint256) {
        int256 price = getLatestPrice();
        // USD amount is in 8 decimal places
        // Price is in 8 decimal places, so we need to adjust the conversion
        return (usdAmount * 10 ** 8) / uint256(price);
    }

    function returnStandardTimestamp() public view returns (uint256) {
        return block.timestamp;
    }

    function timestampMinuteFormat(
        uint256 _timestamp
    ) public pure returns (uint96 _minuteStamp) {
        _minuteStamp = _timestamp / 60;
        return _minuteStamp;
    }
}
