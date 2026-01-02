// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SupplyDBC} from "../../../../../src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibPublishCWavSuppliesHelper {
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
