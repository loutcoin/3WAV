// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library RoyaltyDBC {
    error RoyaltyDBC__NumInputInvalid();
    error RoyaltyDBC__MinEncodedValueInvalid();

    /**
     * @notice Encodes a single raw value related to the cRoyaltyVal ContentToken property.
     * @dev Function called by script to correctly format stored cRoyaltyVal data.
     * @param _royaltyVal Six-digit numerical collaborator royalty split value.
     */
    function _cRoyaltyValEncoder(
        uint32 _royaltyVal
    ) internal pure returns (uint32 _cRoyaltyVal) {
        if (_royaltyVal >= NumericalConstants.SHIFT_7__32) {
            revert RoyaltyDBC__NumInputInvalid();
        }
        _cRoyaltyVal = NumericalConstants.SHIFT_7__32 + _royaltyVal;
        return _cRoyaltyVal;
    }

    /**
     * @notice Decodes encoded input into its underlying raw value for the cRoyaltyVal ContentToken property.
     * @dev Function called by script to decode underlying data stored within cRoyaltyVal.
     * @param _cRoyaltyVal Unsigned interger containing raw cRoyalty definition.
     */
    function _cRoyaltyValDecoder(
        uint32 _cRoyaltyVal
    ) internal pure returns (uint32 _royaltyValRaw) {
        if (_cRoyaltyVal < NumericalConstants.MIN_ENCODED_CROYALTY) {
            revert RoyaltyDBC__MinEncodedValueInvalid();
        }
        _royaltyValRaw = _cRoyaltyVal - NumericalConstants.SHIFT_7__32;
        return _royaltyValRaw;
    }

    /**
     * @notice Encodes six raw values related to the sRoyaltyVal CContentToken property.
     * @dev Function called by script to correctly format stored sRoyaltyVal data.
     * @param _zeroVal Indicates presence of zero value.
     * @param _royalty1 The first six-digit numerical collaborator royalty split.
     * @param _royalty2 The second six-digit numerical collaborator royalty split.
     * @param _royalty3 The third six-digit numerical collaborator royalty split.
     * @param _royalty4 The fourth six-digit numerical collaborator royalty split.
     * @param _royalty5 The fifth six-digit numerical collaborator royalty split.
     * @param _royalty6 The sixth six-digit numerical collaborator royalty split.
     */
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

    /**
     * @notice Decodes encoded input into its seven underlying raw values for the sRoyaltyVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within sRoyaltyVal.
     * @param _royaltyVal Unsigned interger containing multiple compacted seperate sale royalty definitions.
     */
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
}
