// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Content is uniquely identified based on address(artist) and their associated chronologically ordered, sequentially incremented,
numerical contentId index count. Content can further be broken down into a bytes32 'hashId' which provides tamper-proof ID, 
and a method to further distinguish (optionally enabled) STEM track functionality, and content 'Versions'.
'Variants' posses their own unique contentId.
However, 'Versions' are more closely associated to their base material (do not posses distinct seperate associated numerical ID)
*/

contract WavRoot {
    struct CreatorToken {
        address creatorId;
        uint256 contentId;
        bytes32 hashId;
    }

    /*
    related to ownership states of user
    */
    // Tracks current 'content index' of user
    mapping(address userId => uint256 contentIndexId) internal s_ownershipIndex;

    // Maps user wallet address to ordered count for each peice of music they own;
    // represented by music struct.
    mapping(address userId => mapping(uint256 contentIndex => bytes32 hashId))
        internal s_ownershipMap; // possibly used for OwnerReward tracking?????

    mapping(address userId => mapping(bytes32 hashId => uint64 tokenBalance))
        internal s_tokenBalance;

    // Efficiently allows for access and storage with the creator token struct
    // bytes 1st key pair related to content
    mapping(bytes32 hashId => CreatorToken) public s_publishedToken;

    mapping(bytes32 hashId => uint64 remainderSupply) public s_remainingSupply;

    mapping(address => bool) public s_authorizedAddr;

    mapping(uint256 => bool) public s_nonceCheck;
    mapping(address => uint256) internal s_userNonce;
}
