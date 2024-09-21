// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";
import {ECDSA} from "lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MessageHashUtils.sol";

contract WavFortress is WavRoot {
    using ECDSA for bytes32;

    error WavFortress__InvalidNonce();

    function verifySignature(
        bytes32 hash,
        bytes memory signature
    ) internal view returns (address) {
        return MessageHashUtils.toEthSignedMessageHash(hash).recover(signature);
    }

    function checkUseUpdateNonce(uint256 nonce, address _user) internal {
        if (s_nonceCheck[nonce] == true) {
            revert WavFortress__InvalidNonce();
        }
        s_nonceCheck[nonce] = true;
        s_userNonce[_user]++;
    }

    function isAuthorized(address _addr) public view returns (bool) {
        return s_authorizedAddr[addr];
    }

    function getCurrentNonce(address _user) public view returns (uint256) {
        return s_userNonce[user];
    }
}
