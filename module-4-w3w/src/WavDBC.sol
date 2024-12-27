// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @author Matthew Joseph Lout II
/// @title WavDBC
/// @notice Innovative technique (DBC) for efficient data storage and interpretation within smart contracts.
/// @dev Utilizes boolean algebra, bit manipulation, and stored data compaction to reduce gas costs.

// WIP: INCOMPLETE | NON-FUNCTIONAL (WIP)
import {WavToken} from "src/WavToken.sol";

contract WavDBC {
    error WavDBC__LengthValIssue();

    WavToken WAVT;

    /**
     * @notice Routes dynamic quantity of values to determined bit-system.
     * @dev Measures length of total numerical inputs defined, routes for further interpretation.
     * @param _inputVal numerical array of creator-defined inputs.
     */
    function tokenBSDetermine(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {
        if (_inputVal.length == 2) {
            return token1BSInterpreter(_inputVal);
        }
        if (_inputVal >= 3 && _inputVal.length <= 4) {
            return token2BSInterpreter(_inputVal);
        } else if (_inputVal.length > 4 && _inputVal.length <= 8) {
            return token3BSInterpreter(_inputVal);
        } else {
            revert WavDBC__LengthValIssue();
        }
    }

    //

    function token1BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {}

    /**
     * @notice Interprets input data following a 2-bit system.
     * @dev Appends bit-state IDs, and formats returned input into singular compacted value.
     * @param _inputVal numerical array of input values.
     * @return uint256 representing compacted value.
     */
    function token2BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {
        uint256[] memory appendVals = process2BState(_inputVal);
        uint256 result = 0;

        for (uint256 i = 0; i < appendVals.length; i++) {
            result = (result * 100000000) + appendVals[i];
        }

        return result;
    }

    function token3BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {}

    /**
     * @notice Processes input values by delegating operations to sub-functions.
     * @dev Delegates inputs for bit-state assignment, and properly formats them for further compaction.
     * @param _inputVal numerical array of input values.
     * @return uint256[] of input values appended with bit-state identifiers.
     */
    function process2BState(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        if (_inputVal.length < 3 && _inputVal.length > 4) {
            revert WavDBC__LengthValIssue();
        }

        bool has0Val = detect0Val(_inputVal);
        uint256[] memory appendVals = append2BState(_inputVal);

        if (has0Val) {
            appendVals = format0Val(appendVals);
        }

        return appendVals;
    }

    /**
     * @notice Directly assigns numerical bit-state IDs to user-inputs.
     * @dev Multiplies each value by 100 and adds corresponding bit-state identifier.
     * @param _inputVal numerical array of values to which bit-state identifiers are appended.
     * @return array of values with appended bit-state identifiers.
     */
    function assign2BState(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        uint256[] memory appendVals = new uint256[](_inputVal.length);
        uint256[4] memory bitStateID = [0, 1, 10, 11];
        uint256 bitIndex = 0;

        for (uint256 i = 0; i < _inputVal.length; i++) {
            appendVals[i] = (_inputVal[i] * 100) + bitStateID[bitIndex];
            bitIndex++;

            if (bitIndex == 3 && _inputVal.length == 3) {
                bitIndex++;
            }
        }
        if (bitIndex < 4) {
            appendVals[_inputVal.length - 1] =
                appendVals[_inputVal.length - 1] *
                100 +
                bitStateID[bitIndex];
        }

        return appendVals;
    }

    /**
     * @notice Ensures 0Val is correctly formatted within an input array.
     * @dev Checks if the last value is 0Val and formats it to '00000011'.
     * @param appendVals numerical array of values with appended bit-state identifiers.
     * @return array of finalized values.
     */
    function format0Val(
        uint256[] memory appendVals
    ) public pure returns (uint256[] memory) {
        uint256 lastIndex = appendVals.length - 1;
        if (appendVals[lastIndex] / 100 == 0) {
            // Checks if the last value is 0Val
            appendVals[lastIndex] = 11; // Set 0Val as '00000011'
        }
        return appendVals;
    }

    /**
     * @notice Detects presence of 0Val representing undefined and disabled content-states.
     * @dev Inspects numerical array for presence of a 0Val.
     * @param _inputVal numerical array of values to be inspected.
     */
    function detect0Val(uint256[] memory _inputVal) public pure returns (bool) {
        for (uint256 i = 0; i < _inputVal.length; i++) {
            if (_inputVal[i] == 0) {
                return true;
            }
        }
        return false;
    }
}
