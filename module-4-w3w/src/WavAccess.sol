// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

contract WavAccess is WavRoot {
    error WavAccess__NameIsTaken();
    error WavAccess__IsNotApprovedArtist();
    error WavStore__IsNotLout();

    address s_lout;
    address s_WavStore;

    mapping(address => bool) public s_loutTeam;
    mapping(string => address) public s_artistAddr;
    mapping(address => bool) internal s_approvedArtist;

    // called externally outside of DApp, allowing user to register artist account with 'registerArtist'
    function approveArtist(address _userAddress) external {
        onlyLoutDev();
        s_approvedArtist[_userAddress] = true;
    }

    // Function called by approvedArtist set or update their artist profile username
    function updateArtistTag(string memory _name, address _userAddress) public {
        if (s_approvedArtist[msg.sender] != true) {
            revert WavAccess__IsNotApprovedArtist();
        }
        checkNameTaken(_name);
        s_artistAddr[_name] = _userAddress;
    }

    // added access (function call) restrictions needed
    function wavAccess(
        address user,
        uint256 contentId,
        address artist
    ) external {
        uint256 userContentIndex = s_userContentIndex[user];
        s_ownershipAudio[user][userContentIndex] = Music({
            artistId: artist,
            contentId: contentId,
            tokenURI: "", // Add appropriate tokenURI
            isOwner: true
        });
        s_userContentIndex[user]++;
    }

    function onlyLout() internal view {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
    }

    function onlyLoutDev() internal view {
        if (msg.sender != s_lout && !s_loutTeam[msg.sender]) {
            revert WavStore__IsNotLout();
        }
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
}
