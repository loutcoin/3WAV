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
    error WavDBC__BitValIssue();

    WavToken WAVT;

    /**
     * @notice Routes dynamic quantity of values to determined bit-system.
     * @dev Measures length of total numerical inputs defined, routes for further interpretation.
     * @param _inputVal numerical array of creator-defined inputs.
     */
    function tokenBSDetermine(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {
        if (_inputVal.length == 1) {
            return token0BSInterpreter(_inputVal);
        } else if (_inputVal.length == 2) {
            return token1BSInterpreter(_inputVal);
        } else if (_inputVal >= 3 && _inputVal.length <= 4) {
            return token2BSInterpreter(_inputVal);
        } else if (_inputVal.length > 4 && _inputVal.length <= 8) {
            return token3BSInterpreter(_inputVal);
        } else {
            revert WavDBC__LengthValIssue();
        }
    }

    /** 0-bit possibilities: (1: Fully disabled state (0)) (2: 'Fully' enabled state, set to defined value)
    *Low hanging fruit* store single value, bitmap can be assigned to all possible tokens in same var
    
     */

    function token0BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {}

    /**
     * @notice Interprets input values using a 1-bit system and compacts them.
     * @dev Formats values to six digits, appends bit-state identifiers, and compacts them into a single uint256.
     * @param _inputValArray numerical array of input values.
     * @return uint256 representing the compacted values.
     */
    function token1BSInterpreter(
        uint256[] memory _inputValArray
    ) public pure returns (uint256) {
        bool has0Val = detect0Val(_inputValArray);
        uint256[] memory appendVals = assign1BIdentifiers(_inputValArray);

        // Check if the last value is 0Val and format if needed
        if (has0Val) {
            appendVals = format1BZeroVal(appendVals);
        }

        // Compact the values
        uint256 result = (appendVals[0] * 10000000) + appendVals[1];

        return result;
    }

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
            appendVals = format2BZeroVal(appendVals);
        }

        return appendVals;
    }

    /**
     * @notice Formats values to six digits and appends numerical 1-bit state identifiers.
     * @dev Formats each value to six digits, multiplies by 10, and adds corresponding 1-bit state identifier (0 or 1).
     * @param _rInput numerical array of values to which 1-bit state identifiers are appended.
     * @return array of values with formatted and appended 1-bit state identifiers.
     */
    function assign1BIdentifiers(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        uint256[] memory appendedValues = new uint256[](_inputVal.length);
        uint256[2] memory bitStates = [0, 1];

        for (uint256 i = 0; i < _inputVal.length; i++) {
            appendedValues[i] = (_inputVal[i] * 10) + bitStates[i];
        }

        return appendedValues;
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
        uint256[4] memory bitStateId = [0, 1, 10, 11];
        uint256 bitIndex = 0;

        for (uint256 i = 0; i < _inputVal.length; i++) {
            appendVals[i] = (_inputVal[i] * 100) + bitStateId[bitIndex];
            bitIndex++;

            if (bitIndex == 3 && _inputVal.length == 3) {
                bitIndex++;
            }
        }
        if (bitIndex < 4) {
            appendVals[_inputVal.length - 1] =
                appendVals[_inputVal.length - 1] *
                100 +
                bitStateId[bitIndex];
        }

        return appendVals;
    }

    /**
     * @notice Finalizes the appended values by ensuring 0Val is correctly formatted for 1-bit system.
     * @dev Checks if the last value is 0Val and formats it accordingly.
     * @param appendedValues numerical array of values with appended 1-bit state identifiers.
     * @return array of finalized values.
     */
    function format1BZeroVal(
        uint256[] memory appendedValues
    ) public pure returns (uint256[] memory) {
        uint256 lastIndex = appendedValues.length - 1;
        if (appendedValues[lastIndex] == 1) {
            // Checks if the last value is 0Val
            appendedValues[lastIndex] = 1; // Set 0Val as '0000001'
        }
        return appendedValues;
    }

    /**
     * @notice Ensures 0Val is correctly formatted within an input array.
     * @dev Checks if the last value is 0Val and formats it to '00000011'.
     * @param appendVals numerical array of values with appended bit-state identifiers.
     * @return array of finalized values.
     */
    function format2BZeroVal(
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

    /**
     * @notice Assigns a value to enabled flag positions based on 3-bit encoding.
     * @dev Returns bitmap of defined flag states as a chronologically ordered array.
     * @param _typVal Active 3-bit TYP states (string-type).
     * @param _salVal Active 3-bit SAL states (string-type).
     * @param _spyVal Active 3-bit SPY states (string-type).
     * @param _xtrVal Active 3-bit XTR states (string-type).
     * @return _bitVal Complete 3-bit active functional state-map (string-type).
     */
    function flagStateCat(
        string memory _typVal,
        string memory _salVal,
        string memory _spyVal,
        string memory _xtrVal
    ) internal pure returns (string memory _bitVal) {
        // Concatenate the string bitstates from all categories
        string memory _bitVal = string(
            abi.encodePacked(_typVal, _salVal, _spyVal, _xtrVal)
        );

        return _bitVal;
    }

    /**
     * @notice Ensures basic TYP flag format.
     * @dev Returns bitmap of defined flag states as singular compact value.
     * @param _bitStrings numerical array of defined bit position states.
     */
    function processTYPState(
        string[] memory _bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 3) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1], bitStrings[2])
        );

        return combinedString;
    }

    function processSALState(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function processSPYStates(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function processXTRStates(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function creatorTokenFormation(
        address _contentId,
        uint256 _creatorId
    ) public pure returns(CreatorToken memory) {
        CreatorToken memory CRET = new CreatorToken({
            creatorId: _creatorId,
            contentId: _contentId,
            isOwner: true
        });
        return CRET;
    }

    function contentTokenFormation(
        uint16 _numAudio
        uint256 _supplyVal,
        uint256 _priceVal,
        uint256 _releaseVal,
        uint256 _bitVal
    ) public pure returns(ContentToken memory) {
        ContentToken CTKN = new ContentToken({
            numAudio: _numAudio,
            supplyVal: _supplyVal,
            priceVal: _priceVal,
            releaseVal: _releaseVal,
            bitVal: _bitVal
        });
        return CONT;
    }
}
