// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

library ReturnMapMapping {
    /**
     * @notice Retrieves the remaining publically available supply for a token asset.
     * @dev Returns data in 's_cWavSupplies' from 'TokenBalanceStorage.sol'.
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @return _cWavSupplies Remaining collection supplies.
     */
    function returnCWavSupplies(
        bytes32 _hashId
    ) internal view returns (uint112 _cWavSupplies) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        return ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];
    }

    /**
     * @notice Retrieves the remaining publically available supply for a token asset.
     * @dev Returns data in 's_sWavSupplies' from 'TokenBalanceStorage.sol'.
     *      Function Selector:
     * @param _hashId Identifier of Content Token being queried.
     * @param _tierId Tier index attributed to numToken of CContentToken hashId.
     * @return _sWavSupplies Remaining collection supplies.
     */
    function returnSWavSupplies(
        bytes32 _hashId,
        uint16 _tierId
    ) internal view returns (uint112 _sWavSupplies) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        return ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];
    }

    // Needs to be able to return <x> pages depending on numToken input
    function returnSPriceMap(
        bytes32 _hashId,
        uint16 _page
    ) internal view returns (uint256 _priceMap) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        return ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][_page];
    }
}
