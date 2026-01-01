// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    LibFortress
} from "../../src/3WAVi__Helpers/FacetHelpers/LibFortress.sol";

contract WavFortress {
    /**
     * @notice Returns current nonce of authorized address.
     * @dev Returns nonce value contained in s_userNonce mapping.
     * @param _user address
     */
    function getCurrentNonce(address _user) external view returns (uint256) {
        return LibFortress._getCurrentNonce(_user);
    }
}
