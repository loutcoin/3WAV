// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {SupplyDBC} from "../../../../../src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibPublishSWavSuppliesHelper {
    function publishSWavSuppliesHelper(
        uint224 _sSupplyVal,
        uint160 _sReserveVal
    )
        internal
        pure
        returns (
            uint112 _sWavSuppliesTier1,
            uint112 _sWavSuppliesTier2,
            uint112 _sWavSuppliesTier3
        )
    {
        (
            ,
            uint80 _wavReserve1,
            uint80 _wavReserve2,
            uint80 _wavReserve3,
            uint80 _preRelease1,
            uint80 _preRelease2,
            uint80 _preRelease3
        ) = SupplyDBC._sReserveValDecoder(_sReserveVal);

        {
            (
                ,
                uint112 _totalSupply1,
                uint112 _totalSupply2,
                uint112 _totalSupply3,
                ,
                ,

            ) = SupplyDBC._sSupplyValDecoder(_sSupplyVal);

            _wavReserve1 = uint80(
                (uint256(_wavReserve1) * _totalSupply1) / 1_000_000
            );
            _wavReserve2 = uint80(
                (uint256(_wavReserve2) * _totalSupply2) / 1_000_000
            );
            _wavReserve3 = uint80(
                (uint256(_wavReserve3) * _totalSupply3) / 1_000_000
            );
        }

        (
            ,
            ,
            ,
            ,
            uint112 _initialSupply1,
            uint112 _initialSupply2,
            uint112 _initialSupply3
        ) = SupplyDBC._sSupplyValDecoder(_sSupplyVal);

        _sWavSuppliesTier1 = SupplyDBC._remainingSupplyEncoder(
            _initialSupply1,
            uint112(_wavReserve1),
            uint112(_preRelease1)
        );
        _sWavSuppliesTier2 = SupplyDBC._remainingSupplyEncoder(
            _initialSupply2,
            uint112(_wavReserve2),
            uint112(_preRelease2)
        );
        _sWavSuppliesTier3 = SupplyDBC._remainingSupplyEncoder(
            _initialSupply3,
            uint112(_wavReserve3),
            uint112(_preRelease3)
        );

        return (_sWavSuppliesTier1, _sWavSuppliesTier2, _sWavSuppliesTier3);
    }

    function publishCWavSuppliesHelper(
        uint112 _cSupplyVal
    ) internal pure returns (uint112 _cWavSupplies) {
        (
            uint112 _totalSupply,
            uint112 _initialSupply,
            uint112 _wavReservePct,
            uint112 _preReleasePct
        ) = SupplyDBC._cSupplyValDecoder(_cSupplyVal);

        // Convert 6‑digit percentages to literal values
        uint112 _wavReserve = uint112(
            (uint256(_wavReservePct) * _totalSupply) / 1_000_000
        );

        uint112 _preRelease = uint112(
            (uint256(_preReleasePct) * _totalSupply) / 1_000_000
        );

        _cWavSupplies = SupplyDBC._remainingSupplyEncoder(
            _initialSupply,
            _wavReserve,
            _preRelease
        );
    }
}
