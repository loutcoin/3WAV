// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Content is uniquely identified based on address(artist) and their associated chronologically ordered, sequentially incremented,
numerical contentId index count. Content can further be broken down into a bytes32 'hashId' which provides tamper-proof ID, 
and a method to further distinguish (optionally enabled) STEM track functionality, and content 'Versions'.
'Variants' posses their own unique contentId.
However, 'Versions' are more closely associated to their base material (do not posses distinct seperate associated numerical ID)
*/

contract WavRoot {
    struct Music {
        address artistId;
        uint256 contentId;
        uint16 numCollaborators; //uint16 collaborators;??
        bool isOwner; // track ownership
    }

    // Maps user wallet address to ordered count for each peice of music they own;
    // represented by music struct.
    mapping(address user => mapping(uint256 => Music))
        internal s_ownershipAudio; // possibly used for OwnerReward tracking?????
    // Tracks next ordered 'content index' of user
    mapping(address => uint256) internal s_userContentIndex;
    // Efficiently allows for access and storage of contentId associated with addressId in the Music struct
    mapping(address artist => mapping(uint256 content => Music))
        public s_musicFiles;
    mapping(address => bool) public s_authorizedAddr;
    mapping(uint256 => bool) public s_nonceCheck;
    mapping(address => uint256) internal s_userNonce;
}
