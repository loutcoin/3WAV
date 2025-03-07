// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {LibBytes} from "./Libraries/LibBytes.sol";

library LibUtil {
    using LibBytes for bytes;

    function getRevertMsg(
        bytes memory _res
    ) internal pure returns (string memory) {
        // If the _res length is less than 68, then the transaction failed silently (with revert message)
        if (_res.length < 68) return "Transaction reverted silently";
        bytes memory revertData = _res.slice(4, _res.length - 4); // Removes bytes4 selector from message
        return abi.decode(revertData, (string)); // all that remains is the revert string
    }

    /// @notice Determines whether the given address is the zero address
    /// @param _addr The address being verified
    /// @return bool indicates if _addr is the zero address
    function isZeroAddress(address _addr) internal pure returns (bool) {
        return _addr == address(0);
    }

    function revertWith(bytes memory _data) internal pure {
        assembly {
            let dataSize := mload(_data) // Load the size of the data
            let dataPtr := add(_data, 0x20) // Advance data pointer to the next word
            revert(dataPtr, dataSize) // Revert with the given data
        }
    }
}
