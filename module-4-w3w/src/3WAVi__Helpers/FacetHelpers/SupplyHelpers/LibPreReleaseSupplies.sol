// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {SupplyDBC} from "src/3WAVi__Helpers/DBC/SupplyDBC.sol";

import {
    WavSaleToken
} from "../../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

library LibPreReleaseSupplies {
    error PreReleaseSupplies__NumInputInvalid();
    /**
     * @notice Deducts quantity of PreRelease supply and updates the encoded value.
     * @dev Reads s_cWavSupplies and updates active encoded PreRelease supply of hashId.
     *      Function Selector: 0xbeaa0e21
     * @param _hashId Identifier of Content Token being queried.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    function cDebitPreReleaseSupply(
        bytes32 _hashId,
        uint112 _quantity
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[
            _hashId
        ];

        (
            uint112 _wavStoreSupply,
            uint112 _wavReserveSupply,
            uint112 _preReleaseSupply
        ) = SupplyDBC._remainingSupplyDecoder(_remainingSupplies);
        // at '10.000%' returns '100000' should ensure is interpreted / deducted correctly

        if (_quantity == 0 || _preReleaseSupply < _quantity) {
            revert PreReleaseSupplies__NumInputInvalid();
        }

        _preReleaseSupply -= _quantity;

        uint112 _updatedRemainingSupplies = SupplyDBC._remainingSupplyEncoder(
            _wavStoreSupply,
            _wavReserveSupply,
            _preReleaseSupply
        );

        // store _updatedRemainingSupplies
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _hashId
        ] = _updatedRemainingSupplies;
    }

    /**
     * @notice Deducts quantity of PreRelease supply tier and updates the encoded value.
     * @dev Reads s_sWavSupplies and updates active encoded PreRelease supply tier of hashId.
     *      Function Selector: 0x58b030c2
     * @param _hashId Identifier of Content Token being queried.
     * @param _tierId Tier index attributed to numToken of CContentToken hashId.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    function sDebitPreReleaseSupply(
        bytes32 _hashId,
        uint16 _tierId,
        uint112 _quantity
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_sWavSupplies[
            _hashId
        ][_tierId];

        (
            uint112 _wavStoreSupply,
            uint112 _wavReserveSupply,
            uint112 _preReleaseSupply
        ) = SupplyDBC._remainingSupplyDecoder(_remainingSupplies);

        if (_quantity == 0 || _preReleaseSupply < _quantity) {
            revert PreReleaseSupplies__NumInputInvalid();
        }

        _preReleaseSupply -= _quantity;

        uint112 _updatedRemainingSupplies = SupplyDBC._remainingSupplyEncoder(
            _wavStoreSupply,
            _wavReserveSupply,
            _preReleaseSupply
        );

        // store _updatedRemainingSupplies
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            _tierId
        ] = _updatedRemainingSupplies;
    }

    /**
     * @notice Deducts quantity of PreRelease supply tier and updates the encoded value.
     * @dev Reads s_sWavSupplies and updates active encoded PreRelease supply tier of hashId.
     *      Function Selector:
     * @param _wavSaleToken User-defined WavSale struct.
     * @param _tierId Tier index attributed to numToken of CContentToken hashId.
     */
    function sDebitPreReleaseSupplyWavSaleToken(
        WavSaleToken.WavSale calldata _wavSaleToken,
        uint16 _tierId
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_sWavSupplies[
            _wavSaleToken.hashId
        ][_tierId];

        (
            uint112 _wavStoreSupply,
            uint112 _wavReserveSupply,
            uint112 _preReleaseSupply
        ) = SupplyDBC._remainingSupplyDecoder(_remainingSupplies);

        if (
            _wavSaleToken.purchaseQuantity == 0 ||
            _preReleaseSupply < _wavSaleToken.purchaseQuantity
        ) {
            revert PreReleaseSupplies__NumInputInvalid();
        }

        _preReleaseSupply -= _wavSaleToken.purchaseQuantity;

        uint112 _updatedRemainingSupplies = SupplyDBC._remainingSupplyEncoder(
            _wavStoreSupply,
            _wavReserveSupply,
            _preReleaseSupply
        );

        // store _updatedRemainingSupplies
        ContentTokenSupplyMapStruct.s_sWavSupplies[_wavSaleToken.hashId][
            _tierId
        ] = _updatedRemainingSupplies;
    }
}
