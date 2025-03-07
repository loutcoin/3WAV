// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library SpecialLimitedSalesMap {
    bytes32 constant STORAGE_SLOT = keccak256("Special.Limited.Sales.Storage");

    /**
     * @title InAssociation
     * @notice Stores retroactive pairs of association for music tokens
     */
    struct SpecialLimitedSales {
        mapping(bytes32 => uint256 limitedTimeMap) s_limitedTimeSale;
    }

    function inAssociationStorage()
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
