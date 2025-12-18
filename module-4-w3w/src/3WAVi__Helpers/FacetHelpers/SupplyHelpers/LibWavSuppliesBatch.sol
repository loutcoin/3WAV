// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {SupplyDBC} from "src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibWavSuppliesBatch {
    error WavSuppliesBatch__LengthValIssue();
    error WavSuppliesBatch__NumInputInvalid();
    /**
     * @notice Deducts batch quantity of WavStore supply and updates the encoded value.
     * @dev Reads s_cWavSupplies and updates active encoded WavStore supply of hashId.
     *      Function Selector: 0xf81676f8
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _quantityBatch Instances of each Content Token being purchased.
     */
    function cDebitWavStoreSupplyBatch(
        bytes32[] calldata _hashIdBatch,
        uint112[] calldata _quantityBatch
    ) internal {
        if (_hashIdBatch.length != _quantityBatch.length) {
            revert WavSuppliesBatch__LengthValIssue();
        }

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _hashIdBatch.length; ++i) {
            bytes32 _hashId = _hashIdBatch[i];
            uint112 _quantity = _quantityBatch[i];

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct
                .s_cWavSupplies[_hashId];
            (
                uint112 _wavStoreSupply,
                uint112 _wavReserveSupply,
                uint112 _preReleaseSupply
            ) = SupplyDBC._remainingSupplyDecoder(_remainingSupplies);

            if (_quantity == 0 || _wavStoreSupply < _quantity) {
                revert WavSuppliesBatch__NumInputInvalid();
            }

            _wavStoreSupply -= _quantity;

            uint112 _updatedRemainingSupplies = SupplyDBC
                ._remainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                );

            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = _updatedRemainingSupplies;
        }
    }

    /**
     * @notice Deducts batch quantity of WavStore supply and updates the encoded value.
     * @dev Reads s_sWavSupplies and updates active encoded WavStore supply of hashId.
     *      Function Selector: 0x58d94600
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _tierIdBatch The tier value of a particular Content Token.
     * @param _quantityBatch Instances of each Content Token being purchased.
     */
    function sDebitWavStoreSupplyBatch(
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _tierIdBatch,
        uint112[] calldata _quantityBatch
    ) internal {
        if (
            _hashIdBatch.length == 0 ||
            _hashIdBatch.length != _tierIdBatch.length ||
            _hashIdBatch.length != _quantityBatch.length
        ) {
            revert WavSuppliesBatch__LengthValIssue();
        }

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint256 _hashLength = _hashIdBatch.length;
        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint16 _tierId = _tierIdBatch[i];
            uint112 _quantity = _quantityBatch[i];

            uint112 _remainingSupply = ContentTokenSupplyMapStruct
                .s_sWavSupplies[_hashId][_tierId];
            (
                uint112 _wavStoreSupply,
                uint112 _wavReserveSupply,
                uint112 _preReleaseSupply
            ) = SupplyDBC._remainingSupplyDecoder(_remainingSupply);

            if (_quantity == 0 || _wavStoreSupply < _quantity) {
                revert WavSuppliesBatch__NumInputInvalid();
            }

            _wavStoreSupply -= _quantity;

            uint112 _updatedRemainingSupply = SupplyDBC._remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                _tierId
            ] = _updatedRemainingSupply;

            unchecked {
                ++i;
            }
        }
    }
}
