// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibFeed} from "../../src/3WAVi__Helpers/FacetHelpers/LibFeed.sol";

import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";

contract WavFeed {
    /**
     * @notice Assigns a price feed address.
     * @param _priceFeed value being defined as the new active address.
     */
    function setPriceFeed(address _priceFeed) external {
        ReturnValidation.returnIsAuthorized();
        LibFeed._setPriceFeed(_priceFeed);
    }

    /**
     * @notice Returns the current active price feed address.
     * @return address The address value of the active price feed.
     */
    function returnPriceFeedAddress() external view returns (address) {
        return LibFeed._returnPriceFeedAddress();
    }

    /**
     * @notice Returns the latest price.
     * @return int256 The latest price.
     */
    function getLatestPrice() external view returns (int256) {
        return LibFeed._getLatestPrice();
    }

    /**
     * @notice Converts USD amount to ETH.
     * @param _usdVal The amount of USD in 8 decimal places.
     * @return uint256 The equivalent amount in ETH.
     */
    function usdToWei(uint256 _usdVal) external view returns (uint256) {
        return LibFeed._usdToWei(_usdVal);
    }

    /**
     * @notice Converts a batch of USD data into ETH equivalent values.
     * @param _usdValBatch Batch of USD data in 8 decimal places.
     * @return uint256[] The equivalent values in ETH.
     */
    function usdToEthBatch(
        uint256[] calldata _usdValBatch
    ) external view returns (uint256[] memory) {
        return LibFeed._usdToEthBatch(_usdValBatch);
    }
}
