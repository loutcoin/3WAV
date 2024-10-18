// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Additional security to prevent replay attacks and or other potential exploits.
When handling real money, and ownership of digital goods, security is paramount.
*/

import {WavRoot} from "../src/WavRoot.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract WavFortress is WavRoot {
    using ECDSA for bytes32;

    error WavFortress__InvalidNonce();

    /**
     * @notice Verifies a signature.
     * @dev Protects against replay attacks by verifying the authenticity of a signature.
     * @param hash The hash of the signed message.
     * @param signature The signature to be verified.
     * @return address Returns the address that signed the message.
     */
    function verifySignature(
        bytes32 hash,
        bytes memory signature
    ) internal view returns (address) {
        return MessageHashUtils.toEthSignedMessageHash(hash).recover(signature);
    }
    /**
     * @notice Checks the validity of a nonce and updates it.
     * @dev Protects against replay attacks. Ensures the nonce hasn't been used before, then updates associated value.
     * @param nonce The nonce to be checked and updated.
     * @param _user The address of the user whose nonce is being verified.
     */
    function checkUseUpdateNonce(uint256 nonce, address _user) internal {
        if (s_nonceCheck[nonce] == true) {
            revert WavFortress__InvalidNonce();
        }
        s_nonceCheck[nonce] = true;
        s_userNonce[_user]++;
    }
    /**
     * @notice Checks if an address is authorized.
     * @dev Verifies if the provided address is recognized as an authorized address.
     * @param _addr The address to be checked.
     * @return bool Returns true if the address is authorized, false otherwise.
     */
    function isAuthorized(address _addr) public view returns (bool) {
        return s_authorizedAddr[_addr];
    }
    /**
     * @notice Gets the current nonce for a user.
     * @dev Retrieves the latest nonce value for the specified user address.
     * @param _user The address of the user.
     * @return uint256 Returns the current nonce value for the user.
     */
    function getCurrentNonce(address _user) public view returns (uint256) {
        return s_userNonce[_user];
    }
}
