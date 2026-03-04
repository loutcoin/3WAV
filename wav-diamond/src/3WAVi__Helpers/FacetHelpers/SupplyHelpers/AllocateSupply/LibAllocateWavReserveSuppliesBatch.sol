// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    ContentTokenSearchStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

import {
    CContentTokenStorage
} from "../../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    WavSaleToken
} from "../../../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {SupplyDBC} from "src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibAllocateWavReserveSuppliesBatch {
    error AllocateWavReserveSuppliesBatch__NumInputInvalid();
    error AllocateWavReserveSuppliesBatch__InsufficientUnallocated();
    error AllocateWavReserveSuppliesBatch__BranchError404();

    /**
     * @notice Allocates unallocated supplies to the WavReserve.
     * @dev Uses existing supply properties and remainingSupply values.
     * @param _wavSaleToken User-defined array of WavSale structs.
     */
    function _allocateUnallocatedToWavReserveBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal {
        {
            if (_wavSaleToken.length == 0) {
                revert AllocateWavReserveSuppliesBatch__NumInputInvalid();
            }
        }

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage SupplyMap = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        ContentTokenSearchStorage.ContentTokenSearch
            storage Search = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ++i) {
            WavSaleToken.WavSale calldata _wST = _wavSaleToken[i];

            if (_wST.purchaseQuantity == 0) {
                revert AllocateWavReserveSuppliesBatch__NumInputInvalid();
            }

            {
                SContentTokenStorage.SContentToken storage _sCTKN = Search
                    .s_sContentTokenSearch[_wST.hashId];

                // Branch 1: SContentToken (numToken == 0)
                if (_sCTKN.supplyVal != 0 && _wST.numToken == 0) {
                    (uint112 _totalSupply, , , ) = SupplyDBC._cSupplyValDecoder(
                        _sCTKN.supplyVal
                    );

                    uint112 _remainingSupply = SupplyMap.s_cWavSupplies[
                        _wST.hashId
                    ];

                    (
                        uint112 _wavStore,
                        uint112 _wavReserve,
                        uint112 _preRelease
                    ) = SupplyDBC._remainingSupplyDecoder(_remainingSupply);

                    {
                        uint112 _allocated = _wavStore +
                            _wavReserve +
                            _preRelease;
                        if (_allocated > _totalSupply) {
                            revert AllocateWavReserveSuppliesBatch__NumInputInvalid();
                        }

                        uint112 _unallocated = _totalSupply - _allocated;
                        if (_wST.purchaseQuantity > _unallocated) {
                            revert AllocateWavReserveSuppliesBatch__InsufficientUnallocated();
                        }
                    }

                    _wavReserve += _wST.purchaseQuantity;

                    uint112 _updated = SupplyDBC._remainingSupplyEncoder(
                        _wavStore,
                        _wavReserve,
                        _preRelease
                    );

                    SupplyMap.s_cWavSupplies[_wST.hashId] = _updated;
                    continue;
                }
            }

            CContentTokenStorage.CContentToken storage _cCTKN = Search
                .s_cContentTokenSearch[_wST.hashId];

            // Branch 2: CContentToken (numToken == 0)
            if (_cCTKN.cSupplyVal != 0 && _wST.numToken == 0) {
                (uint112 _totalSupply, , , ) = SupplyDBC._cSupplyValDecoder(
                    _cCTKN.cSupplyVal
                );

                uint112 _remainingSupply = SupplyMap.s_cWavSupplies[
                    _wST.hashId
                ];

                (
                    uint112 _wavStore,
                    uint112 _wavReserve,
                    uint112 _preRelease
                ) = SupplyDBC._remainingSupplyDecoder(_remainingSupply);

                {
                    uint112 _allocated = _wavStore + _wavReserve + _preRelease;
                    if (_allocated > _totalSupply) {
                        revert AllocateWavReserveSuppliesBatch__NumInputInvalid();
                    }

                    uint112 _unallocated = _totalSupply - _allocated;
                    if (_wST.purchaseQuantity > _unallocated) {
                        revert AllocateWavReserveSuppliesBatch__InsufficientUnallocated();
                    }
                }

                _wavReserve += _wST.purchaseQuantity;

                uint112 _updated = SupplyDBC._remainingSupplyEncoder(
                    _wavStore,
                    _wavReserve,
                    _preRelease
                );

                SupplyMap.s_cWavSupplies[_wST.hashId] = _updated;

                continue;
            }

            // Branch 3: CContentToken (numToken != 0)
            if (_cCTKN.cSupplyVal != 0 && _wST.numToken != 0) {
                uint16 _wordIndex = _wST.numToken >> 6;
                uint8 _within = uint8(_wST.numToken & 63);

                uint256 _packed = SupplyMap.s_tierMap[_wST.hashId][_wordIndex];
                uint256 _shift = uint256(_within) * 4;
                uint8 _tierId = uint8((_packed >> _shift) & 0xF);

                _tierId++;

                uint112 _remainingSupply = SupplyMap.s_sWavSupplies[
                    _wST.hashId
                ][_tierId];

                (
                    uint112 _wavStore,
                    uint112 _wavReserve,
                    uint112 _preRelease
                ) = SupplyDBC._remainingSupplyDecoder(_remainingSupply);

                {
                    uint112 _totalSupply = SupplyDBC._sSupplyValState(
                        _tierId,
                        _cCTKN.sSupplyVal
                    );

                    uint112 _allocated = _wavStore + _wavReserve + _preRelease;
                    if (_allocated > _totalSupply) {
                        revert AllocateWavReserveSuppliesBatch__NumInputInvalid();
                    }

                    uint112 _unallocated = _totalSupply - _allocated;
                    if (_wST.purchaseQuantity > _unallocated) {
                        revert AllocateWavReserveSuppliesBatch__InsufficientUnallocated();
                    }
                }

                _wavReserve += _wST.purchaseQuantity;

                uint112 _updated = SupplyDBC._remainingSupplyEncoder(
                    _wavStore,
                    _wavReserve,
                    _preRelease
                );

                SupplyMap.s_sWavSupplies[_wST.hashId][_tierId] = _updated;
            } else {
                revert AllocateWavReserveSuppliesBatch__BranchError404();
            }
        }
    }
}
