// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Additional security to prevent replay attacks and or other potential exploits.
When handling real money, and ownership of digital goods, security is paramount.
*/

import {
    LibFortress
} from "../../src/3WAVi__Helpers/FacetHelpers/LibFortress.sol";

contract WavFortress {
    function getCurrentNonce(address _user) external view returns (uint256) {
        return LibFortress._getCurrentNonce(_user);
    }
}
