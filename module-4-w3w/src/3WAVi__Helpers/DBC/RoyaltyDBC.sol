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
    ) internal pure returns (uint128 _royaltyVal) {
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
        _royaltyVal += uint128(uint256(_royalty1) * 10 ** 30);
        _royaltyVal += uint128(uint256(_royalty2) * 10 ** 24);
        _royaltyVal += uint128(uint256(_royalty3) * 10 ** 18);
        _royaltyVal += uint128(uint256(_royalty4) * 10 ** 12);
        _royaltyVal += uint128(uint256(_royalty5) * 10 ** 6);
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
        _royalty1 = uint32((_royaltyVal / 10 ** 30) % 10 ** 6);
        _royalty2 = uint32((_royaltyVal / 10 ** 24) % 10 ** 6);
        _royalty3 = uint32((_royaltyVal / 10 ** 18) % 10 ** 6);
        _royalty4 = uint32((_royaltyVal / 10 ** 12) % 10 ** 6);
        _royalty5 = uint32((_royaltyVal / 10 ** 6) % 10 ** 6);
        _royalty6 = uint32(_royaltyVal % 10 ** 6);
    }

    function _cRoyaltyValEncoder(
        uint32 _royaltyVal
    ) internal pure returns (uint32 _cRoyaltyVal) {
        if (_royaltyVal >= NumericalConstants.SHIFT_7__32) {
            revert RoyaltyDBC__NumInputInvalid();
        }
        _cRoyaltyVal = NumericalConstants.SHIFT_7__32 + _royaltyVal;
        return _cRoyaltyVal;
    }

    function _cRoyaltyValDecoder(
        uint32 _cRoyaltyVal
    ) internal pure returns (uint32 _royaltyValRaw) {
        if (_cRoyaltyVal < NumericalConstants.MIN_ENCODED_CROYALTY) {
            revert RoyaltyDBC__MinEncodedValueInvalid();
        }
        _royaltyValRaw = _cRoyaltyVal - NumericalConstants.SHIFT_7__32;
        return _royaltyValRaw;
    }
}
