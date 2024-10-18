// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

/* Allows for myself/team to grant access to individuals to become official artists (capable of publishing content)
Preforms automated cryptographic key checks to return verified 'owned content' accessible in library.
(Can only access content either YOU published as an artist, OR that you've PURCHASED!)
*/

contract WavAccess is WavRoot {
    error WavAccess__NameIsTaken();
    error WavAccess__IsNotApprovedArtist();
    error WavStore__IsNotLout();

    address internal s_lout;
    /**
     * @notice Stores information regarding availability of artistTags.
     * @dev Maps a string artistTag against an address artistId.
     */
    mapping(string => address) public s_artistAddr;
    /**
     * @notice Stores information regarding a creator account's official artist status.
     * @dev Maps an address artistId to a boolean representing account status.
     */
    mapping(address => bool) internal s_approvedArtist;

    /**
     * @notice Approves a user account to become an artist account.
     * @dev Function only callable by authorized personnel to update user account to an artist account.
     * @param _userAddress The address of the user to be approved as an artist.
     */
    function approveArtist(address _userAddress) external {
        onlyAuthorized();
        s_approvedArtist[_userAddress] = true;
    }

    // added access (function call) restrictions needed
    /**
     * @notice Grants access to a specific content listing after purchase.
     * @dev This function is used to grant user access to content created by an artist.
     * @param user The address of the user receiving access.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _numCollaborators The number of collaborators involved in the content creation.
     */
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

    /**
     * @notice Sets or updates the artist profile username.
     * @dev Function called by an approved artist to set or update their profile username.
     * @param _artistTag The new username for the artist profile.
     * @param _artistId The address of the artist.
     */
    function updateArtistTag(
        string memory _artistTag,
        address _artistId
    ) public {
        if (s_approvedArtist[msg.sender] != true) {
            revert WavAccess__IsNotApprovedArtist();
        }
        checkNameTaken(_artistTag);
        s_artistAddr[_artistTag] = _artistId;
    }

    /**
     * @notice Returns an array of all content owned by a particular user.
     * @dev Function called in a gasless manner to update/refresh user content library.
     * @param user The address of the user whose content ownership is being queried.
     * @return Music[] An array of all content the user owns.
     */
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
    /**
     * @notice Checks if an artist profile username is already taken.
     * @dev Ensures that the desired username is not already associated with another artist.
     * @param _artistTag The username to be checked.
     */
    function checkNameTaken(string memory _artistTag) public view {
        if (s_artistAddr[_artistTag] != address(0)) {
            revert WavAccess__NameIsTaken();
        }
    }

    /**
     * @notice Ensures that the function is called only by authorized personnel.
     * @dev Internal function that reverts if the caller is not an authorized address.
     */
    function onlyAuthorized() internal view {
        if (msg.sender != s_lout && !s_authorizedAddr[msg.sender]) {
            revert WavStore__IsNotLout();
        }
    }
}
