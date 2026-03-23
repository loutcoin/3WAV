// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {SupplyDBC} from "../../../../../src/3WAVi__Helpers/DBC/SupplyDBC.sol";

library LibPublishCWavSuppliesHelper {
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
