// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library RoyaltyDBC {
    error RoyaltyDBC__NumInputInvalid();
    error RoyaltyDBC__MinEncodedValueInvalid();

    function royaltyValEncoder(
        uint8 _zeroVal,
        uint32 _royalty1,
        uint32 _royalty2,
        uint32 _royalty3,
        uint32 _royalty4,
        uint32 _royalty5,
        uint32 _royalty6
    ) external pure returns (uint128 _royaltyVal) {
        if (
            _zeroVal > 1 ||
            _royalty1 >= NumericalConstants.SHIFT_7__32 ||
            _royalty2 >= NumericalConstants.SHIFT_7__32 ||
            _royalty3 >= NumericalConstants.SHIFT_7__32 ||
            _royalty4 >= NumericalConstants.SHIFT_7__32 ||
            _royalty5 >= NumericalConstants.SHIFT_7__32 ||
            _royalty6 >= NumericalConstants.SHIFT_7__32
        ) {
            revert RoyaltyDBC__NumInputInvalid();
        }
        _royaltyVal = uint128(10 ** 38);

        if (_zeroVal == 1) {
            _royaltyVal += uint128(10 ** 36);
        }
        _royaltyVal += uint128(uint256(_royalty1) * 10 ** 31);
        _royaltyVal += uint128(uint256(_royalty2) * 10 ** 25);
        _royaltyVal += uint128(uint256(_royalty3) * 10 ** 19);
        _royaltyVal += uint128(uint256(_royalty4) * 10 ** 13);
        _royaltyVal += uint128(uint256(_royalty5) * 10 ** 7);
        _royaltyVal += uint128(_royalty6);

        return _royaltyVal;
    }

    function _royaltyValDecoder(
        uint128 _royaltyVal
    )
        internal
        pure
        returns (
            uint8 _zeroVal,
            uint32 _royalty1,
            uint32 _royalty2,
            uint32 _royalty3,
            uint32 _royalty4,
            uint32 _royalty5,
            uint32 _royalty6
        )
    {
        if (_royaltyVal < NumericalConstants.MIN_ENCODED_ROYALTY) {
            revert RoyaltyDBC__MinEncodedValueInvalid();
        }
        _zeroVal = uint8((_royaltyVal / 10 ** 36) % 10);
        if (_zeroVal > 1) {
            revert RoyaltyDBC__MinEncodedValueInvalid();
        }
        _royalty1 = uint32((_royaltyVal / 10 ** 31) % 10 ** 6);
        _royalty2 = uint32((_royaltyVal / 10 ** 25) % 10 ** 6);
        _royalty3 = uint32((_royaltyVal / 10 ** 19) % 10 ** 6);
        _royalty4 = uint32((_royaltyVal / 10 ** 13) % 10 ** 6);
        _royalty5 = uint32((_royaltyVal / 10 ** 7) % 10 ** 6);
        _royalty6 = uint32(_royaltyVal % 10 ** 6);
    }
}
