// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {SupplyDBC} from "src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibWavReserveSupplies {
    error WavReserveSupplies__NumInputInvalid();
    /**
     * @notice Deducts quantity of WavReserve supply and updates the encoded value.
     * @dev Reads s_cWavSupplies and updates active encoded WavReserve supply of hashId.
     *      Function Selector: 0x21373ff6
     * @param _hashId Identifier of Content Token being queried.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    function cDebitWavReserve(bytes32 _hashId, uint112 _quantity) internal {
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

        if (_quantity == 0 || _wavReserveSupply < _quantity) {
            revert WavReserveSupplies__NumInputInvalid();
        }

        _wavReserveSupply -= _quantity;

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
     * @notice Deducts quantity of WavReserve supply tier and updates the encoded value.
     * @dev Reads s_sWavSupplies and updates active encoded WavReserve supply tier of hashId.
     *      Function Selector: 0x40cb439e
     * @param _hashId Identifier of Content Token being queried.
     * @param _tierId Tier index attributed to numToken of CContentToken hashId.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    function sDebitWavReserve(
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

        if (_quantity == 0 || _wavReserveSupply < _quantity) {
            revert WavReserveSupplies__NumInputInvalid();
        }

        _wavReserveSupply -= _quantity;

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
}
