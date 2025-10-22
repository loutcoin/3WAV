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
    error WavAccess__LengthMismatch();
    error WavAccess__InsufficientReserves();
    /**
     * @notice Approves a user account to become an artist account.
     * @dev Function only callable by authorized personnel to update user account to an artist account.
     * @param _userAddress The address of the user to be approved as an artist.
     */
    /*   function approveArtist(address _userAddress) external {
        ReturnValidation.onlyAuthorized();
        s_approvedArtist[_userAddress] = true; // SHOULD INSTEAD CHECK s_addrToAlias != 0
    } */

    
    /**
     * @notice Grants Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Total instances of numToken to debit.
     */
    function wavAccess(
        address _buyer,
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _purchaseQuantity
    ) internal {
        onlyAuthorized();
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();
        
        // Increase _buyer s_tokenBalance by _purchaseQuantity
        TokenBalanceStruct.s_tokenBalance[_buyer][_hashId][_numToken] += _purchaseQuantity;

        // Record ownership entry for _buyer
        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[_buyer];
        CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][_hashId] = _numToken;
        CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;
    }

    
    /**
    * @notice Grants batch Content Token access during sale conducted through official service channels
    * @dev This function is used to grant access to content purchased via non-human service channels.
    * @param _buyer The address of the buyer.
    * @param _hashIdBatch Batch of Content Token identifier values being queried.
    * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
    * @param _purchaseQuantityBatch Total instances of each numToken being debited.
    */
    function wavAccessBatch(
        address _buyer,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint256[] calldata _purchaseQuantityBatch
    ) internal {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(
            _numTokenBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength
        ) {
            revert WavAccess__LengthMismatch();
        }

        CreatorTokenMapStorage.CreatorTokenMap storage CreatorTokenMapStruct =
        CreatorTokenMapStorage.creatorTokenMapStructStorage();
        TokenBalanceStorage.TokenBalance storage TokenBalanceStruct =
        TokenBalanceStorage.tokenBalanceStorage();

        for(uint256 i = 0; i < _hashLength;) {
            bytes32 _hashId = _hashIdBatch[i];
            uint16 _numToken = _numTokenBatch[i];
            uint256 _purchaseQuantity = _purchaseQuantityBatch[i];

            // Increase buyer token balance
            TokenBalanceStruct.s_tokenBalance[_buyer][_hashId][_numToken] += _purchaseQuantity;

            // Record ownership entry for buyer
            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[_buyer];
            CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][_hashId] = _numToken;
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;

            unchecked { ++i; }
        }
    } 


    /**
    * @notice Exchanges access of Content Tokens during user resale execution.
    * @dev This function is used to exchange access of content from peer to peer.
    * @param _buyer The address of the buyer.
    * @param _seller The address of the seller.
    * @param _hashId Identifier of Content Token being queried.
    * @param _numToken Content Token identifier used to specify the token index being queried.
    * @param _purchaseQuantity Total instances of numToken to debit.
    */
    function wavExchange(
        address _buyer,
        address _seller
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _purchaseQuantity
    ) external {
        onlyAuthorized();
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[_seller][_hashId][_numToken];
        if(_sellerBalance < _purchaseQuantity) revert WavAccess__InsufficientReserves();
        
        TokenBalanceStruct.s_tokenBalance[_seller][_hashId][_numToken] = _sellerBalance - _purchaseQuantity;

        TokenBalanceStruct.s_tokenBalance[_buyer][_hashId][
            _numToken
        ] += _purchaseQuantity;

        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _buyer
        ];

        /* Due to updated mapping structure removed conditional that preforms extra verification
        to ensure ownershipIndex is not occupied before writing data to the position.
        It should be impossible for this to happen anyways, unless there is a defect elsewhere. */

        CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
            _hashId
        ] = _numToken;

        CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;
    }

    
    /**
    * @notice Exchanges access of a Content Token batch during user resale execution.
    * @dev This function is used to exchange access of content from peer to peer.
    * @param _buyer The address of the buyer.
    * @param _sellerBatch Batch of seller addresses.
    * @param _hashIdBatch Batch of Content Token identifier values being queried.
    * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
    * @param _purchaseQuantityBatch Total instances of each numToken being debited.
    */
    function wavExchangeBatch(
        address _buyer,
        address[] calldata _sellerBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint256[] calldata _purchaseQuantityBatch
    ) external {
        onlyAuthorized();
        uint256 _hashLength = _hashIdBatch.length;
        // Length property of all arrays should match
        if (
            _sellerBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength
        ) {
            revert WavAccess__LengthMismatch();
        }
        // Load storage pointers
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        // Iterate and assign each asset
        for (uint256 i = 0; i < _hashLength; ) {
            // Grab user current ownershipIndex
            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
                _buyer
            ];

            // Update ownership map with _hashId and _numToken values
            CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][_hashIdBatch[i]] =
            _numTokenBatch[i];

            // Increment Index for next asset
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;

            // Seller balance check and debit
            address _seller = _sellerBatch[i];
            uint256 _purchaseQuantity = _purchaseQuantityBatch[i];
            uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[_seller][_hashIdBatch[i]][
                _numTokenBatch[i]
            ];
            if(_sellerBalance < _purchaseQuantity) revert WavAccess__InsufficientReserves();
            TokenBalanceStruct.s_tokenBalance[_seller][_hashIdBatch[i]][_numTokenBatch[i]] =
            _sellerBalance - _purchaseQuantity;

            // Update buyer balances
            TokenBalanceStruct.s_tokenBalance[_buyer][_hashIdBatch[i]][_numTokenBatch[i]] +=
            _purchaseQuantity;

            unchecked {
                ++i;
            }
        } 
    }



         // Update ownership map with _hashId and _numToken values
      /*      CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
                _hashIdBatch[i]
            ] = _numTokenBatch[i];

            // Increment index for next asset
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] =
                _ownershipIndex +
                1;

            TokenBalanceStruct.s_tokenBalance[_sellerBatch[i]][_hashIdBatch[i]][
                _numTokenBatch[i]
            ] -= _purchaseQuantityBatch[i];

            // Update token balances
            TokenBalanceStruct.s_tokenBalance[_buyer][_hashIdBatch[i]][
                _numTokenBatch[i]
            ] += _purchaseQuantityBatch[i];

            unchecked {
                ++i;
            } */

    /* function wavRevokeSingle(
        address _userAddr,
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _quantity
    ) external {

    } */

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
            ownedContentToken[i] = s_ownershipMap[_userAddr][i]; // used to be s_ownershipAudio
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
