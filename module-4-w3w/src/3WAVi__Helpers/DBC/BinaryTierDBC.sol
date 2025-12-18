// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

library BinaryTierDBC {
    /**
     * @notice Returns the tier index of specified numToken in relation to hashId.
     * @dev Reads 256-bit word that contains 4-bit tier slot for 64 tokens, extracts 4-bit value attributed to numToken input.
     *      Function Selector: 0x2be87751
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     */
    function _getTier(
        bytes32 _hashId,
        uint16 _numToken
    ) internal view returns (uint8) {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        uint16 _wordIndex = _numToken >> 6;
        uint8 _within = uint8(_numToken & 63);

        uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[_hashId][
            _wordIndex
        ];
        // 4 bits per token
        uint256 _shift = uint256(_within) * 4;
        uint8 _tierId = uint8((_packed >> _shift) & 0xF);

        return _tierId;
    }
}
