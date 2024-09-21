// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

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
    // Efficiently allows for access and storage of contentId associated with addressId in the Music strcut
    mapping(address artist => mapping(uint256 content => Music))
        public s_musicFiles;
    mapping(address => bool) public s_authorizedAddr;
    mapping(uint256 => bool) public s_nonceCheck;
    mapping(address => uint256) internal s_userNonce;
}
