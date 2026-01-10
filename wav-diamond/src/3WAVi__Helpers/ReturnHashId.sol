// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

library ReturnHashId {
    /**
     * @notice Generates a unique hash identifier for a specific track or version.
     * @dev Combines artist's address, content ID, variant number, audio number, and track version to generate a unique bytes32 hash.
     * @param _creatorId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _variantIndex Variant index of Content Token publish context.
     * @return bytes32 The unique hash identifier for the track or version.
     */
    function returnHashId(
        address _creatorId,
        uint256 _contentId,
        uint16 _variantIndex
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_creatorId, _contentId, _variantIndex));
    }
}
