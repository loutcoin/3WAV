// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

import {ReturnValidation} from "../src/3WAVi__Helpers/ReturnValidation.sol";
import {ReturnMapping} from "../src/3WAVi__Helpers/ReturnMapping.sol";

import {AuthorizedAddrs} from "../Diamond__Storage/ActiveAddresses/AuthorizedAddrs.sol";

import {CreatorAliasMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorAliasMapStorage.sol";
import {CreatorTokenStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {CreatorTokenMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {TokenBalanceStorage} from "../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";

/* Allows for myself/team to grant access to individuals to become official artists (capable of publishing content)
Preforms automated cryptographic key checks to return verified 'owned content' accessible in library.
(Can only access content either YOU published as an artist, OR that you've PURCHASED!)
*/

contract WavAccess is WavRoot {
    error WavAccess__IndexIssue();
    error WavAccess__NameIsTaken();
    error WavAccess__NotApprovedArtist();
    error WavAccess__IsNotLout();
    error WavAccess__AliasUndefined();
    error WavAccess__AlreadyCertified();

    /**
     * @notice Approves a user account to become an artist account.
     * @dev Function only callable by authorized personnel to update user account to an artist account.
     * @param _userAddress The address of the user to be approved as an artist.
     */
    /*   function approveArtist(address _userAddress) external {
        ReturnValidation.onlyAuthorized();
        s_approvedArtist[_userAddress] = true; // SHOULD INSTEAD CHECK s_addrToAlias != 0
    } */

    // added access (function call) restrictions needed
    /**
     * @notice Grants access to a specific content token post-purchase. Does not directly affect supply.
     * @dev This function is used to grant user access to content created by an creator.
     * @param _userAddr The address of the user receiving access.
     * @param _ownershipIndex The historical ownership index of the user.
     * @param _hashId The unique hashId of the content token itself.
     */
    function wavAccess(
        address _userAddr,
        uint256 _ownershipIndex,
        uint256 _purchaseQuantity,
        bytes32 _hashId
    ) external {
        onlyAuthorized();
        if (returnOwnershipMap(_userAddr, _ownershipIndex) != bytes32(0)) {
            revert WavAccess__IndexIssue();
        }
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        CreatorTokenMapStruct.s_ownershipMap[_userAddr][
            _ownershipIndex
        ] = _hashId;
        TokenBalanceStruct.s_tokenBalance[_userAddr][
            _hashId
        ] += _purchaseQuantity;

        CreatorTokenMapStruct.s_ownershipIndex[_userAddr]++; //can be done last
    }

    /**
     * @notice Sets or updates the artist profile username.
     * @dev Function called by an approved artist to set or update their profile username.
     *      Function Selector: 0x419b261d
     * @param _creatorAlias The new username for the artist profile.
     * @param _creatorId The address of the artist.
     */
    function certifyAlias(
        string memory _creatorAlias,
        address _creatorId
    ) external {
        // Ensures account is not already certified.
        if (returnAddrToAlias(_creatorId) != "0") {
            revert WavAccess__AlreadyCertified();
        }
        // Ensures Alias is available.
        checkAlias(_creatorAlias);

        // Accesses the CreatorAlias struct storage slot.
        CreatorAliasMapStorage.CreatorAlias
            storage CreatorAliasMapStruct = CreatorAliasMapStorage
                .creatorAliasStructStorage();

        // Writes to instances of the contained mappings, updating a Creator Alias.
        CreatorAliasMapStruct.s_aliasToAddr[_creatorAlias] = _creatorId;
        CreatorAliasMapStruct.s_addrToAlias[_creatorId] = _creatorAlias;
    }

    /**
     * @notice Sets or updates the artist profile username.
     * @dev Function called by an approved artist to set or update their profile username.
     *      Function Selector: 0xa7875f43
     * @param _creatorAlias The new username for the artist profile.
     * @param _creatorId The address of the artist.
     */
    function modifyAlias(
        string memory _creatorAlias,
        address _creatorId
    ) external {
        // Ensures Alias is available.
        checkAlias(_creatorAlias);

        if (_creatorId == address(0) && _creatorAlias == "0") {
            revert WavAccess__IsNotApprovedArtist(); // invalid inputs.
        }

        // Accesses the CreatorAlias struct storage slot.
        CreatorAliasMapStorage.CreatorAlias
            storage CreatorAliasMapStruct = CreatorAliasMapStorage
                .creatorAliasStructStorage();

        // Writes to instances of the contained mappings, updating a Creator Alias.
        CreatorAliasMapStruct.s_aliasToAddr[_creatorAlias] = _creatorId;
        CreatorAliasMapStruct.s_addrToAlias[_creatorId] = _creatorAlias;
    }

    /**
     * @notice Returns an array of all content owned by a particular user.
     * @dev Function called in a gasless manner to update/refresh user content library.
     *      Function Selector: 0x2a8e407b
     * @param address _userAddr The address of the user whose content ownership is being queried.
     * @return CreatorToken[] An array of all owned CreatorToken assets.
     */
    function returnOwnership(
        address _userAddr
    ) external view returns (CreatorToken[] memory) {
        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenStorage
                .creatorTokenStructStorage();
        uint256 contentCount = CreatorTokenStruct.s_userContentIndex[_userAddr];
        CreatorTokenStruct[]
            memory ownedContentToken = new CreatorTokenStruct[](contentCount);

        for (uint256 i = 0; i < contentCount; i++) {
            ownedContentToken[i] = s_ownershipAudio[user][i];
        }

        return ownedContentToken;
    }
    /**
     * @notice Checks if an alias is already taken.
     * @dev Ensures that the alias value is not associated with another CreatorId.
     *      Function Selector: 0xd97eaaa9
     * @param _creatorAlias The username to be checked.
     */
    function checkAlias(string memory _creatorAlias) external view {
        address _creatorId = returnAliasToAddr(_creatorAlias);
        if (_creatorId != 0) revert WavAccess__AliasUndefined();
    }

    /**
     * @notice Removes an address from the list of authorized addresses.
     * @dev Callable exclusively by current address(s_lout). Removes an address authorized access.
     * @param _addr The address to removed from the authorized list.
     */
    function removeApprovedAddr(address _addr) external {
        onlyAuthorized();
        AuthorizedAddrs.AuthorizedAddrMap
            storage authorizedAddrStruct = AuthorizedAddrs
                .authorizedAddrStorage();
        authorizedAddrStruct.s_isAuthorizedAddr[_addr] = false;
    }

    /// correct these functions here:

    /**
     * @notice Adds a new address to the list of currently authorized addresses.
     * @dev Callable exclusively by authorized addresses. Grants authorized access to specified address.
     * @param _addr The address to authorize.
     */
    function addApprovedAddr(address _addr) external {
        if (!s_authorizedAddrs[msg.sender]) {
            revert WavStore__IsNotLout();
        }
        s_authorizedAddr[_addr] = true;
    }

    /**
     * @notice Updates the Lout address to a new address.
     * @dev Exclusive to current address(s_lout). Updates state to reflect new official address(s_lout).
     * @param _newLoutAddr The new Lout address.
     */
    function updateLoutAddr(address _newLoutAddr) external {
        onlyLout();
        s_lout = _newLoutAddr;
    }
}
