// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ECDSA
} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

import {
    MessageHashUtils
} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

import {
    ECDSAStorage
} from "../../../src/Diamond__Storage/ECDSA/ECDSAStorage.sol";

library LibFortress {
    using ECDSA for bytes32;

    error WavFortress__InvalidNonce();

    /**
     * @notice Verifies a signature.
     * @dev Protects against replay attacks by verifying the authenticity of a signature.
     * @param hash The hash of the signed message.
     * @param signature The signature to be verified.
     * @return address Returns the address that signed the message.
     */
    function _verifySignature(
        bytes32 hash,
        bytes memory signature
    ) internal pure returns (address) {
        return MessageHashUtils.toEthSignedMessageHash(hash).recover(signature);
    }

    /**
     * @notice Checks the validity of a nonce and updates it.
     * @dev Protects against replay attacks. Ensures the nonce hasn't been used before, then updates associated value.
     * @param nonce The nonce to be checked and updated.
     * @param _user The address of the user whose nonce is being verified.
     */
    function _checkUseUpdateNonce(uint256 nonce, address _user) internal {
        ECDSAStorage.ECDSAMap storage ECDSAStruct = ECDSAStorage
            .returnECDSAStorage();
        if (ECDSAStruct.s_nonceCheck[nonce] == true) {
            revert WavFortress__InvalidNonce();
        }
        ECDSAStruct.s_nonceCheck[nonce] = true;
        ECDSAStruct.s_userNonce[_user]++;
    }

    /**
     * @notice Gets the current nonce for a user.
     * @dev Retrieves the latest nonce value for the specified user address.
     * @param _user The address of the user.
     * @return uint256 Returns the current nonce value for the user.
     */
    function _getCurrentNonce(address _user) internal view returns (uint256) {
        ECDSAStorage.ECDSAMap storage ECDSAStruct = ECDSAStorage
            .returnECDSAStorage();
        return ECDSAStruct.s_userNonce[_user];
    }
}
