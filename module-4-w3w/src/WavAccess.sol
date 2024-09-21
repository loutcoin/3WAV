// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

contract WavAccess is WavRoot {
    error WavAccess__NameIsTaken();
    error WavAccess__IsNotApprovedArtist();
    error WavStore__IsNotLout();

    address internal s_lout;

    mapping(address => bool) public s_loutTeam;
    mapping(string => address) public s_artistAddr;
    mapping(address => bool) internal s_approvedArtist;

    // called externally outside of DApp, allowing user to register artist account with 'registerArtist'
    function approveArtist(address _userAddress) external {
        onlyAuthorized();
        s_approvedArtist[_userAddress] = true;
    }

    // added access (function call) restrictions needed
    function wavAccess(
        address user,
        address _artistId,
        uint256 _contentId,
        uint16 _numCollaborators
    ) external {
        uint256 userContentIndex = s_userContentIndex[user];
        s_ownershipAudio[user][userContentIndex] = Music({
            artistId: _artistId,
            contentId: _contentId,
            numCollaborators: _numCollaborators,
            isOwner: true
        });
        s_userContentIndex[user]++;
    }

    // Function called by approvedArtist set or update their artist profile username
    function updateArtistTag(string memory _name, address _userAddress) public {
        if (s_approvedArtist[msg.sender] != true) {
            revert WavAccess__IsNotApprovedArtist();
        }
        checkNameTaken(_name);
        s_artistAddr[_name] = _userAddress;
    }

    function returnOwnership(
        address user
    ) public view returns (Music[] memory) {
        uint256 contentCount = s_userContentIndex[user];
        Music[] memory ownedMusic = new Music[](contentCount);

        for (uint256 i = 0; i < contentCount; i++) {
            ownedMusic[i] = s_ownershipAudio[user][i];
        }

        return ownedMusic;
    }

    function checkNameTaken(string memory _name) public view {
        if (s_artistAddr[_name] != address(0)) {
            revert WavAccess__NameIsTaken();
        }
    }

    function onlyAuthorized() internal view {
        if (msg.sender != s_lout && !s_authorizedAddr[msg.sender]) {
            revert WavStore__IsNotLout();
        }
    }
}
