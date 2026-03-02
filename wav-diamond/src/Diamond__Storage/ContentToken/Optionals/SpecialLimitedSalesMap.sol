// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library SpecialLimitedSalesMap {
    bytes32 constant STORAGE_SLOT = keccak256("Special.Limited.Sales.Storage");

    /**
     * @title SpecialLimitedSalesMap
     * @notice Stores limited time sale map of hashId.
     */
    struct SpecialLimitedSales {
        mapping(bytes32 => uint256 limitedTimeMap) s_limitedTimeSale;
    }

    function specialLimitedSalesMap()
        internal
        pure
        returns (SpecialLimitedSales storage SpecialLimitedSalesStruct)
    {
        bytes32 _storageSlot = STORAGE_SLOT;
        assembly {
            SpecialLimitedSalesStruct.slot := _storageSlot
        }
    }
}
