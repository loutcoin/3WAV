// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library Binary3BitDBC {
    error Binary3BitDBC__LengthValIssue();
    error Binary3BitDBC__BitValIssue();
    error Binary3BitDBC__MinEncodedValueInvalid();
    function _encode3BitState(
        uint16[] calldata _indexArray,
        uint8[] calldata _stateArray
    ) internal pure returns (uint256 _bitmap) {
        if (
            _indexArray.length != _stateArray.length ||
            _indexArray.length < 1 ||
            _indexArray.length > 85
        ) {
            revert Binary3BitDBC__LengthValIssue();
        }

        uint256 _result = 0;
        for (uint256 i = 0; i < _indexArray.length; ++i) {
            uint16 _index = _indexArray[i];
            uint8 _state = _stateArray[i];

            if (_index >= 85 || _state >= 8) {
                revert Binary3BitDBC__BitValIssue();
            }

            uint256 _mask = ~(uint256(0x7) << (3 * _index));
            uint256 _insert = uint256(_state) << (3 * _index);

            _result = (_result & _mask) | _insert;
        }

        if (_result == 0) {
            revert Binary3BitDBC__MinEncodedValueInvalid();
        }

        return _result;
    }

    function _decode3BitState(
        uint256 _bitmap,
        uint16 _numToken
    ) internal pure returns (uint8 _value) {
        if (_numToken >= 85) {
            revert Binary3BitDBC__LengthValIssue();
        }
        return uint8((_bitmap >> (3 * _numToken)) & 0x7);
    }

    function _get3BitMapPage(
        uint256[] storage _arrayMap,
        uint16 _numToken
    ) internal view returns (uint256 _bitmap, uint16 _arrayIndex) {
        uint16 _page = _numToken / 85;
        _arrayIndex = _numToken - _page * 85;

        if (_page >= _arrayMap.length) {
            _bitmap = 0;
        } else {
            _bitmap = _arrayMap[_page];
        }
    }
}
