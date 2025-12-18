// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SupplyDBC} from "../../../../src/3WAVi__Helpers/DBC/SupplyDBC.sol";

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
            ,
            ,
            ,
            uint112 _initialSupply1,
            uint112 _initialSupply2,
            uint112 _initialSupply3
        ) = SupplyDBC._sSupplyValDecoder(_sSupplyVal);

        (
            ,
            uint80 _wavReserve1,
            uint80 _wavReserve2,
            uint80 _wavReserve3,
            uint80 _preRelease1,
            uint80 _preRelease2,
            uint80 _preRelease3
        ) = SupplyDBC._sReserveValDecoder(_sReserveVal);

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
            ,
            uint112 _initialSupply,
            uint112 _wavReserve,
            uint112 _preRelease
        ) = SupplyDBC._cSupplyValDecoder(_cSupplyVal);
        _cWavSupplies = SupplyDBC._remainingSupplyEncoder(
            _initialSupply,
            _wavReserve,
            _preRelease
        );
    }
}
