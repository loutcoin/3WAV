// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* '0x97d9F9A00dEE0004BE8ca0A8fa374d486567eE2D' (ETH:USD) (Polygon zkEVM) (8 decimal)
Preforms gasless live price calculations, uses data to pass along function calls
*/

import {LibFeed} from "../../src/3WAVi__Helpers/FacetHelpers/LibFeed.sol";
import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";

contract WavFeed {
    /**
     * @notice Assigns a price feed address.
     * @dev Function Selector: 0x724e78da
     * @param _priceFeed value being defined as the new active address.
     */
    function setPriceFeed(address _priceFeed) external {
        ReturnValidation.returnIsAuthorized();
        LibFeed._setPriceFeed(_priceFeed);
    }

    function returnPriceFeedAddress() external view returns (address) {
        return LibFeed._returnPriceFeedAddress();
    }

    function getLatestPrice() external view returns (int256) {
        return LibFeed._getLatestPrice();
    }

    function convertEthToUsd(
        uint256 _ethAmount
    ) external view returns (uint256) {
        return LibFeed._convertEthToUsd(_ethAmount);
    }

    function usdToWei(uint256 _usdVal) external view returns (uint256) {
        return LibFeed._usdToWei(_usdVal);
    }

    function usdToEthBatch(
        uint256[] calldata _usdValBatch
    ) external view returns (uint256[] memory) {
        return LibFeed._usdToEthBatch(_usdValBatch);
    }

    function convertUsdToEth(uint256 _usdVal) external view returns (uint256) {
        return LibFeed._convertUsdToEth(_usdVal);
    }
}
