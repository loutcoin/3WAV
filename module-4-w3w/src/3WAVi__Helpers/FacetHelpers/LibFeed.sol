// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    FacetAddrStorage
} from "../../../src/Diamond__Storage/ActiveAddresses/FacetAddrStorage.sol";

import {
    AggregatorV3Interface
} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library LibFeed {
    error LibFeed__InvalidPrice();
    error LibFeed__InvalidInput();

    /**
     * @notice Assigns a price feed address.
     * @dev Function Selector: 0x724e78da
     * @param _priceFeed value being defined as the new active address.
     */
    function _setPriceFeed(address _priceFeed) internal {
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        if (_priceFeed == address(0)) revert LibFeed__InvalidInput();
        // Or 'FacetAddrStructStorage.s_priceFeed(_priceFeed);
        FacetAddrStructStorage.s_priceFeed = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Returns the current active price feed address.
     * @dev Function Selector: 0xa4dfcacd
     * @return address The address value of the active price feed.
     */
    function _returnPriceFeedAddress() internal view returns (address) {
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        return address(FacetAddrStructStorage.s_priceFeed);
    }

    /**
     * @notice Returns the latest price.
     * @dev Function Selector: 0x8e15f473
     * @return int256 The latest price.
     */
    function _getLatestPrice() internal view returns (int256) {
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        (, int256 price, , , ) = FacetAddrStructStorage
            .s_priceFeed
            .latestRoundData();
        return price;
    }

    /**
     * @notice Converts USD amount to ETH.
     * @dev Function Selector: 0xa3053e2a
     * @param _usdVal The amount of USD in 8 decimal places.
     * @return uint256 The equivalent amount in ETH.
     */
    function _usdToWei(uint256 _usdVal) internal view returns (uint256) {
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        (, int256 _priceInt, , , ) = FacetAddrStructStorage
            .s_priceFeed
            .latestRoundData();

        if (_priceInt == 0) {
            revert LibFeed__InvalidPrice();
        }

        uint256 _price8 = uint256(_priceInt);

        uint256 _usd8 = _usdVal * 1e6; // 10^(8 - 2) = 1e6

        uint256 _ethWei = (_usd8 * 1e18) / _price8;

        return _ethWei;
    }

    /**
     * @notice Converts a batch of USD data into ETH equivalent values.
     * @dev Function Selector:
     * @param _usdValBatch Batch of USD data in 8 decimal places.
     * @return _ethWeiBatch The equivalent values in ETH.
     */
    function _usdToEthBatch(
        uint256[] calldata _usdValBatch
    ) internal view returns (uint256[] memory _ethWeiBatch) {
        // priceFeed call for all items:
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        (, int256 _priceInt, , , ) = FacetAddrStructStorage
            .s_priceFeed
            .latestRoundData();
        if (_priceInt == 0) {
            revert LibFeed__InvalidPrice();
        }
        uint256 _price8 = uint256(_priceInt);

        uint256 _amountLength = _usdValBatch.length;
        _ethWeiBatch = new uint256[](_amountLength);

        // Compute _usdValBatch to _ethWeiBatch
        for (uint256 i = 0; i < _amountLength; ) {
            uint256 _usd6 = _usdValBatch[i] * 1e6;
            _ethWeiBatch[i] = (_usd6 * 1e18) / _price8;
            unchecked {
                ++i;
            }
        }

        return _ethWeiBatch;
    }
}
