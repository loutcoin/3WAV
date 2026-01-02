// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library PriceDBC {
    error ReleaseDBC__NumInputInvalid();
    error ReleaseDBC__MinEncodedValueInvalid();
    /**
     * @notice Standardizes the digit count of cPriceUsdVal.
     * @dev Function called by script to standardize digit count of cPriceUsdVal.
     *      Function Selector: 0xb9879684
     * @param _cPriceUsdInput Raw unsigned interger price definition.
     */
    function _cPriceUsdValEncoder(
        uint32 _cPriceUsdInput
    ) internal pure returns (uint32 _cPriceUsdVal) {
        if (_cPriceUsdInput > 1999999999) {
            revert ReleaseDBC__NumInputInvalid();
        }
        _cPriceUsdVal =
            NumericalConstants.LEADING_TEN__THIRTY_TWO_BIT +
            _cPriceUsdInput;
        return _cPriceUsdVal;
    }

    /** // need to add conditional to ensure input does not exceed 1999999999
     * @notice Decodes cPriceUsdVal into its underlying value input.
     * @dev Function called by script to decode underlying data stored within cPriceUsdVal.
     *      Function Selector: 0xb7dc9ade
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
     */
    function _cPriceUsdValDecoder(
        uint32 _cPriceUsdVal
    ) internal pure returns (uint32 _cPriceUsdRaw) {
        if (_cPriceUsdVal < NumericalConstants.MIN_ENCODED_CPRICE_USD_VAL) {
            revert ReleaseDBC__MinEncodedValueInvalid();
        }
        _cPriceUsdRaw =
            _cPriceUsdVal -
            NumericalConstants.LEADING_TEN__THIRTY_TWO_BIT;
        return _cPriceUsdRaw;
    }

    /**
     * @notice Encodes four raw values related to the 30-digit sPriceUsdVal CContentToken property.
     * @dev Function called by script to correctly format stored sPriceUsdVal data.
     *      Function Selector: 0x6fb1d5e3
     * @param _zeroVal Indicates presence of zero value.
     * @param _standardPriceVal Standard numerical USD value assignable to Content Tokens seperately sold.
     * @param _accessiblePriceVal Optional lesser numerical USD value assignable to Content Tokens seperately sold.
     * @param _exclusivePriceVal Optional greater numerical USD value assignable to Content Tokens seperately sold.
     */
    function _sPriceUsdValEncoder(
        uint8 _zeroVal,
        uint112 _standardPriceVal,
        uint112 _accessiblePriceVal,
        uint112 _exclusivePriceVal
    ) internal pure returns (uint112 _sPriceUsdVal) {
        // ensures inputs are less than 10 digits and _zeroVal is no greater than '1'
        if (
            _standardPriceVal >= NumericalConstants.SHIFT_10 ||
            _accessiblePriceVal >= NumericalConstants.SHIFT_10 ||
            _exclusivePriceVal >= NumericalConstants.SHIFT_10 ||
            _zeroVal > 1 ||
            _standardPriceVal == 0
        ) {
            revert ReleaseDBC__NumInputInvalid();
        }
        // (if no _zeroVal '101...') else '100...')
        if (_zeroVal == 1) {
            _sPriceUsdVal =
                NumericalConstants.SHIFT_30 +
                NumericalConstants.SHIFT_28;
        } else {
            _sPriceUsdVal = NumericalConstants.SHIFT_30;
        }
        _sPriceUsdVal += _standardPriceVal * NumericalConstants.SHIFT_19;
        _sPriceUsdVal += _accessiblePriceVal * NumericalConstants.SHIFT_10;
        _sPriceUsdVal += _exclusivePriceVal;
        return _sPriceUsdVal;
    }

    /**
     * @notice Decodes encoded input into its underlying four raw values for the sPriceUsdVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within sPriceUsdVal.
     *      Function Selector: 0x814a4248
     * @param _sPriceUsdVal Unsigned interger containing multiple compacted seperate sale definitions.
     */
    function _sPriceUsdValDecoder(
        uint112 _sPriceUsdVal
    )
        internal
        pure
        returns (
            uint8 _zeroVal,
            uint112 _standardPriceVal,
            uint112 _accessiblePriceVal,
            uint112 _exclusivePriceVal
        )
    {
        if (_sPriceUsdVal < NumericalConstants.MIN_ENCODED_SPRICE_USD_VAL) {
            revert ReleaseDBC__MinEncodedValueInvalid();
        }
        // Extract 'zeroVal'
        _zeroVal = uint8((_sPriceUsdVal / NumericalConstants.SHIFT_28) % 10);
        if (_zeroVal > 1) {
            revert ReleaseDBC__MinEncodedValueInvalid();
        }
        // Extract '_standardPriceVal'
        _standardPriceVal =
            (_sPriceUsdVal / NumericalConstants.SHIFT_19) %
            NumericalConstants.SHIFT_10;
        // Extract '_accessiblePriceVal'
        _accessiblePriceVal =
            (_sPriceUsdVal / NumericalConstants.SHIFT_10) %
            NumericalConstants.SHIFT_10;
        // Extract '_exclusivePriceVal'
        _exclusivePriceVal = _sPriceUsdVal % NumericalConstants.SHIFT_10;
        return (
            _zeroVal,
            _standardPriceVal,
            _accessiblePriceVal,
            _exclusivePriceVal
        );
    }

    /**
     * @notice Determines numerical value correlated to bit state of a hashId.
     * @dev Function called during Content Token price validation.
     *      Function Selector: 0x48992985
     * @param _bitState Attributed symbolic binary state associated with user-defined numerical value.
     * @param _sPriceUsdVal Unsigned interger containing multiple numerical value states.
     */
    function _sPriceUsdValState(
        uint8 _bitState,
        uint112 _sPriceUsdVal
    ) internal pure returns (uint112) {
        if (_bitState == 1) {
            (, , uint112 _accessiblePriceVal, ) = _sPriceUsdValDecoder(
                _sPriceUsdVal
            );
            return _accessiblePriceVal;
        }
        if (_bitState == 2) {
            (, uint112 _standardPriceVal, , ) = _sPriceUsdValDecoder(
                _sPriceUsdVal
            );
            return _standardPriceVal;
        }
        if (_bitState == 3) {
            (, , , uint112 _exclusivePriceVal) = _sPriceUsdValDecoder(
                _sPriceUsdVal
            );
            return _exclusivePriceVal;
        }
    }
}
