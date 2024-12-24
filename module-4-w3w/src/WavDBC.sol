// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @author Matthew Joseph Lout II
/// @title WavDBC
/// @notice Innovative technique (DBC) for efficient data storage and interpretation within smart contracts.
/// @dev Utilizes boolean algebra, bit manipulation, and stored data compaction to reduce gas costs.


// WIP: INCOMPLETE | NON-FUNCTIONAL (WIP)
import {WavToken} from "src/WavToken.sol";

contract WavDBC {
    error WavDBC__RSaleMismatch();

    WavToken WAVT;
    
    
    /**
    * @notice Assigns and routes input to 2-bit or 3-bit interpretation.
    * @dev Measures length property of _rInput value to determine bit-compatibility.
     */
     function rDBDetermination(uint256[] memory _rInput) public pure returns (uint256) {
        if (_rInput.length >= 2 && _rInput.length < 4) { 
            return rSale2Interpreter(_rInput); }
        else if (_rInput.length > 4 && _rInput.length < 8) { 
            return rSale3Interpreter(_rInput); }
        else { 
            revert WavDBC__RSaleMismatch(); } 
           }



    function rSale2Interpreter(uint256[] memory _rInput) public pure returns(uint256) {
        if(_rInput.length > 4) { // 25.5005, 10.0000, 01.0001, 00.0000
           revert WavDBC__RSaleMismatch();
        }
        
        uint256 result = 0;

        for(uint256 i = 0; i <= _rInput.length; i++) {
            if(_rInput[i] > 999999) {
                WavToken__RSaleOverflow();
            }
            result = (result << 26) | _rInput[i];
        }
        return result;
    }

    function rSale3Interpreter(uint256[] memory _rInput) public pure returns(uint256) {
        if(_rInput.length <= 4 || _rInput.length > 8) {
            revert WavToken__RSaleMismatch();
        }
        uint256 result = 0;
        
        for(uint256 i = 0; i <= _rInput.length; i++) {
            if(_rInput[i] > 999999) {
                WavToken__RSaleOverflow();
            }
        }
    }




}