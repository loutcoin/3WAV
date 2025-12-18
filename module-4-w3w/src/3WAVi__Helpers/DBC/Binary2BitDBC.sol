// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library Binary2BitDBC {
    error Binary2BitDBC__LengthValIssue();
    error Binary2BitDBC__BitValIssue();
    error Binary2BitDBC__MinEncodedValueInvalid();
    /**
     * @notice Creates a price map using symbolic binary states for a sPriceUsdVal property of a cContentToken.
     * @dev Takes a dynamic quantity of index values correlated to 2-bit binary states which are attributed in chronological order.
     *      Function Selector: 0x1e310e88
     * @param _indexArray Total quantity of index values stored as numToken property data.
     * @param _stateArray Correlating quantity of symbolic bit states attributed numerical user-defined price value(s).
     */
    function _encode2BitStates(
        uint16[] calldata _indexArray,
        uint8[] calldata _stateArray
    ) internal pure returns (uint256 _resultVal) {
        if (
            _indexArray.length != _stateArray.length ||
            _indexArray.length < 1 ||
            _indexArray.length > 127
        ) {
            revert Binary2BitDBC__LengthValIssue();
        }
        _resultVal = 0;

        for (uint256 i = 0; i < _indexArray.length; ++i) {
            uint16 _index = _indexArray[i]; // corrected uint8 => uint16
            uint8 _state = _stateArray[i];
            if (_index >= 128 || _state >= 4) {
                revert Binary2BitDBC__BitValIssue();
            }
            // Prepare math to clear bits at index
            uint256 _mask = ~(uint256(0x3)) << (2 * _index);
            // Insert 2-bit value
            uint256 _encodedVal = uint256(_state) << (2 * _index);
            // Clear existing bits at index, insert new value
            _resultVal = (_resultVal & _mask) | _encodedVal;
        }
        // Ensures one or more index is non-zero bitstate
        if (_resultVal == 0) {
            revert Binary2BitDBC__MinEncodedValueInvalid();
        }

        return _resultVal;
    }

    /**
     * @notice Decodes and returns binary state of numToken value from valid encoded bitMap.
     * @dev Takes an encoded priceMap property and returns binary state of specified numToken index.
     *      Function Selector: 0x1e310e88
     * @param _bitmap priceMap associated with cContentToken.
     * @param _numToken numToken index being queried.
     */
    function _decode2BitState(
        uint256 _bitmap,
        uint16 _numToken
    ) internal pure returns (uint8 _value) {
        if (_numToken >= 128) {
            revert Binary2BitDBC__LengthValIssue();
        }
        return uint8((_bitmap >> (2 * _numToken)) & 0x3);
    }
}
