// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    CreatorTokenMapStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";

import {
    TokenBalanceStorage
} from "../../../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

library LibAccess {
    /**
     * @notice Grants Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _wavSaleToken User-defined WavSale struct
     */
    function _wavAccess(
        address _buyer,
        WavSaleToken.WavSale calldata _wavSaleToken
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        // Increase _buyer s_tokenBalance by _purchaseQuantity
        TokenBalanceStruct.s_tokenBalance[_buyer][_wavSaleToken.hashId][
            _wavSaleToken.numToken
        ] += uint256(_wavSaleToken.purchaseQuantity);

        // Record ownership entry for _buyer
        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _buyer
        ];
        CreatorTokenMapStruct.s_ownershipMap[_buyer][
            _ownershipIndex
        ] = _wavSaleToken.hashId;
        CreatorTokenMapStruct.s_ownershipToken[_buyer][
            _ownershipIndex
        ] = _wavSaleToken.numToken;
        CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;
    }
}
