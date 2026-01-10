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

library LibAccessBatch {
    error WavAccess__LengthMismatch();

    /**
     * @notice Grants batch Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _wavAccessBatch(
        address _buyer,
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;
            uint16 _numToken = _wavSaleToken[i].numToken;
            uint256 _purchaseQuantity = uint256(
                _wavSaleToken[i].purchaseQuantity
            );

            // Increase buyer token balance
            TokenBalanceStruct.s_tokenBalance[_buyer][_hashId][
                _numToken
            ] += _purchaseQuantity;

            // Record ownership entry for buyer
            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
                _buyer
            ];

            CreatorTokenMapStruct.s_ownershipMap[_buyer][
                _ownershipIndex
            ] = _hashId;
            CreatorTokenMapStruct.s_ownershipToken[_buyer][
                _ownershipIndex
            ] = _numToken;
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] =
                _ownershipIndex +
                1;

            unchecked {
                ++i;
            }
        }
    }
}
