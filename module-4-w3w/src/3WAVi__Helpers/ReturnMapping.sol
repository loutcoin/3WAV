// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TokenBalanceStorage} from "../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";
import {CreatorTokenMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {CreatorProfitStorage} from "../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol"; // haven't did functions here. Considerations 2be made.
import {CreatorAliasMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorAliasMapStorage.sol";
// ContentToken
import {ContentTokenSearchStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
import {ContentTokenPriceMapStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenPriceMapStorage.sol";

// ContentToken/Optionals
import {VariantMapStorage} from "../src/Diamond__Storage/ContentToken/Optionals/VariantMapStorage.sol";
import {VersionStemStorage} from "../src/Diamond__Storage/ContentToken/Optionals/VersionStemStorage.sol";

// Active Addresses
import {AuthorizedAddrs} from "../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrs.sol";




library ReturnMapping {
    
    function returnIsAuthorizedAddr(address _userId) internal view returns(bool _authorizedAddr){
            return s_isAuthorizedAddr[_userId];
        
    }

    function returnEthEarnings(address _creatorId, bytes32 _hashId) internal view returns(uint256 _earnings) {
        _earnings = s_ethEarnings[_creatorId][_hashId];
        return _earnings;
    }

    /** 
     * @notice Retrieves the remaining publically available supply for a token asset.
     * @dev Returns data in 's_remainingSupply' from 'TokenBalanceStorage.sol'.
     *      Function Selector: 0x1c0ab7f1
     * @param _hashId The hashId of the token.
     * @return uint256 _remainingSupply.
     */
    function returnRemainingSupply(
        bytes32 _hashId
    ) internal view returns (uint256 _remainingSupply) {
        return s_remainingSupply[_hashId];
    } 

    /**
     * @notice Retrieves an asset-type token balance of an address.
     * @dev Returns data in 's_tokenBalance' from 'TokenBalanceStorage.sol'.
     *      Function Selector: 0x2f3c8bd1
     * @param _userId The address of the balance being inquired.
     * @param _hashId The hashId of the token.
     * @return uint256 _tokenBalance.
     */
    function returnTokenBalance(
        address _userId
        bytes32 _hashId
    ) internal view returns (uint256 _tokenBalance) {
        _tokenBalance = s_tokenBalance[_userId][_hashId];
        return _tokenBalance;
    }

    /**
    * @notice Retrieves basic token identifier data derived from 'CreatorToken'.
    * @dev Returns data in 's_publishedTokenData' from 'CreatorTokenMapStorage.sol'.
    *      Function Selector: 0x37971d82
    * @param _hashId The hashId of the token.
    * @return CreatorToken instance-specific token identifier properties.
    */
    function returnPublishedTokenData(
        bytes32 _hashId
    ) internal view returns(CreatorToken memory) {
        return s_publishedTokenData[_hashId];
    }

    /**
    * @notice Retrieves the publisher address, from a provided hashId.
    * @dev Returns data in 's_publishedTokenData' from 'CreatorTokenMapStorage.sol'.
    *      Function Selector: 0x7df01a17
    * @param _hashId The hashId of the token.
    * @return address of the publisher.
    */
    function returnTokenPublisher(
        bytes32 _hashId
    ) internal view returns(address) {
        return s_publishedTokenData[_hashId].creatorId;
    }

    /**
    * @notice Retrieves the publisher address, and contentId from a provided hashId.
    * @dev Returns data in 's_publishedTokenData' from 'CreatorTokenMapStorage.sol'.
    *      Function Selector: 0x86ff8ed0
    * @param _hashId The hashId of the token.
    * @return address of the publisher.
    * @return uint256 Content Token index.
    */
    function returnCreatorTokenData(
        bytes32 _hashId
    ) internal view returns(address, uint256) {
        return (s_publishedTokenData[_hashId].creatorId, s_publishedTokenData[_hashId].contentId);
    }

    /**
    * @notice Retrieves an incremental index count related to user asset ownership.
    * @dev Returns data in 's_ownershipIndex' from 'CreatorTokenMapStorage.sol'.
    *      Function Selector: 0x5b3074cd
    * @param _userId The address associated to the index count.
    * @return uint256 _indexCount of the user.
    */
    function returnOwnershipIndex(
        address _userId
    ) internal view returns(uint256 _indexCount) {
        return s_ownershipIndex[_userId];
    }

    /**
    * @notice Retrieves an incremental index count related to user asset ownership.
    * @dev Returns data in 's_ownershipMap' from 'CreatorTokenMapStorage.sol'.
    *      Function Selector: 0x5e1577d0
    * @param _userId The address associated to the index count.
    * @param _indexCount Chronological index of asset-type ownership associated to an address.
    * @return bytes32 _hashId of a token-asset found at the _indexCount of a provided address.
    */
    function returnOwnershipMap(
        address _userId,
        uint256 _indexCount,
    ) internal view returns(bytes32 _hashId) {
        _hashId = s_ownershipMap[_userId][_indexCount];
        return _hashId;
    }

    /**
    * @notice Retrieves an incremental index count related to user asset ownership.
    * @dev Returns data in 's_aliasToAddr' from 'CreatorAliasMapStorage.sol'.
    *      Function Selector: 0x0408e4f5
    * @param _userId The address associated to the index count.
    * @param _alias Chronological index of asset-type ownership associated to an address.
    * @return address _creatorId 
    */
    function returnAliasToAddr(
        string memory _alias
    ) internal view returns(address _creatorId) {
        return s_aliasToAddr[_alias];
    }

    /**
    * @notice Retrieves an incremental index count related to user asset ownership.
    * @dev Returns data in 's_addrToAlias' from 'CreatorAliasMapStorage.sol'.
    *      Function Selector: 0x6f4ba8b2
    * @param _creatorId The address associated to the index count.
    * @return string _alias
    */
    function returnAddrToAlias(
        address _creatorId
    ) internal view returns(string memory _alias) {
        return s_addrToAlias[_creatorId];
    }


    /**
    * @notice Retrieves incremental user nonce count.
    * @dev Returns data in 's_userNonce' from 'ECDSAStorage.sol'.
    *      Function Selector: 0xfd3c1d14
    * @param _userId The address associated to the index count.
    * @return uint256 _nonce value.
    */
    function returnUserNonce(
        address _userId
    ) internal view returns(uint256 _nonce) {
        return s_userNonce[_userId];
    }

    /**
    * @notice Retrieves explict property values of a Content Collective Token.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xf5e22195
    * @param _hashId of the Collective Content Token.
    * @return CContentToken associated to the hashId
    */
    function returnCContentTokenSearch(
        bytes32 _hashId
    ) internal view returns(CContentToken memory) {
        return s_cContentTokenSearch[_hashId];
    }

    /**
    * @notice Retrieves the number of tokens compromising a Content Collective Token.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xc17d5286
    * @param _hashId of the Content Collective Token.
    * @return uint24 numToken of a Content Collective Token.
    */
      function returnCContentTokenNumToken(
        bytes32 _hashId
    ) internal view returns(uint24) {
        return s_cContentTokenSearch[_hashId].numToken
    }

    /**
    * @notice Retrieves core supply definitions of a Content Collective Token entity. 
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x4119e1ec
    * @param _hashId of the Content Collective Token.
    * @return uint104 cSupplyVal of a Content Collective Token.
    */
    function returnCContentTokenCSupplyVal(
        bytes32 _hashId
    ) internal view returns(uint104) {
        return s_cContentTokenSearch[_hashId].cSupplyVal;
    }

    /**
    * @notice Retrieves seperate supply definitions of members within a Content Collective Token.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x862b255f
    * @param _hashId of the Content Collective Token.
    * @return uint104 sSupplyVal of a Content Collective Token.
    */
     function returnCContentTokenSPriceUsdVal(
        bytes32 _hashId
    ) internal view returns(uint104) {
        return s_cContentTokenSearch[_hashId].sPriceUsdVal;
    }

    /**
    * @notice Retrieves core USD price definition of a Content Collective Token entity.
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x929b1943
    * @param _hashId of the Content Collective Token.
    * @return uint32 cPriceUsdVal of a Content Collective Token.
    */
      function returnCContentTokenCPriceUsdVal(
        bytes32 _hashId
    ) internal view returns(uint32) {
        return s_cContentTokenSearch[_hashId].cPriceUsdVal;
    }

    /**
    * @notice Retrieves core total supply values of a Content Collective Token entity.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x2349552f
    * @param _hashId of the Content Collective Token.
    * @return uint104 cTotalSupplyVal of a Content Collective Token.
    */
     function returnCContentTokenSTotalSupply(
        bytes32 _hashId
    ) internal view returns(uint104) {
        return s_cContentTokenSearch[_hashId].cTotalSupply;
    }

    /**
    * @notice Retrieves core initial supply values of a Content Collective Token entity.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x47c3ae2c
    * @param _hashId of the Content Collective Token.
    * @return uint104 cInitialSupply of a Content Collective Token.
    */
     function returnCContentTokenSInitialSupply(
        bytes32 _hashId
    ) internal view returns(uint104) {
        return s_cContentTokenSearch[_hashId].cInitialSupply;
    }

    /**
    * @notice Retrieves WavReserve values for members of a Content Collective Token.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xfcc0790a
    * @param _hashId of the Content Collective Token.
    * @return uint80 sWavR of a Content Collective Token.
    */
    function returnCContentTokenSWavR(
        bytes32 _hashId
    ) internal view returns(uint80) {
        return s_cContentTokenSearch[_hashId].sWavR;
    }

    /**
    * @notice Retrieves PreSaleReserve values for members of a Content Collective Token.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x62952717
    * @param _hashId of the Content Collective Token.
    * @return uint80 sPreSaleR of a Content Collective Token.
    */
     function returnCContentTokenSPreSaleR(
        bytes32 _hashId
    ) internal view returns(uint80) {
        return s_cContentTokenSearch[_hashId].sPreSaleR;
    }

    /**
    * @notice Retrieves core time-based sale properties of a Content Collective Token entity.
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xfb42d534
    * @param _hashId of the Content Collective Token.
    * @return uint96 releaseVal of a Content Collective Token.
    */
     function returnCContentTokenReleaseVal(
        bytes32 _hashId
    ) internal view returns(uint96) {
        return s_cContentTokenSearch[_hashId].cReleaseVal;
    }

    /**
    * @notice Retrieves enabled and disabled 3-bit functional flag states of a Content Collective Token
    * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xe3465187
    * @param _hashId of the Standard Content Token.
    * @return uint256 bitVal of a Content Collective Token.
    */
    function returnCContentTokenBitVal(
        bytes32 _hashId
    ) internal view returns(uint256) {
        return s_cContentTokenSearch[_hashId].bitVal;
    }

    /**
    * @notice Retrieves explict property values of a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xf053e568
    * @param _hashId of the Standard Content Token.
    * @return SContentToken associated to the hashId
    */
    function returnSContentTokenSearch(
        bytes32 _hashId
    ) internal view returns(SContentToken memory) {
        return s_sContentTokenSearch[_hashId];
    }


    /**
    * @notice Retrieves the number of tokens compromising a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x9812b925
    * @param _hashId of the Standard Content Token.
    * @return uint24 numToken of a Standard Content Token.
    */
    function returnSContentTokenNumToken(
        bytes32 _hashId
    ) internal view returns(uint24) {
        return s_sContentTokenSearch[_hashId].numToken
    }

    /**
    * @notice Retrieves the USD price definition of a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xf366cd7f
    * @param _hashId of the Standard Content Token.
    * @return uint32 priceUsdVal of a Standard Content Token.
    */
    function returnSContentTokenPriceUsdVal(
        bytes32 _hashId
    ) internal view returns(uint32) {
        return s_sContentTokenSearch[_hashId].priceUsdVal;
    }

    /**
    * @notice Retrieves the raw supply definitions of a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xf45af9d4
    * @param _hashId of the Standard Content Token.
    * @return uint104 supplyVal of a Standard Content Token.
    */
    function returnSContentTokenSupplyVal(
        bytes32 _hashId
    ) internal view returns(uint104) {
        return s_sContentTokenSearch[_hashId].supplyVal;
    }

    /**
    * @notice Retrieves time-based sale properties of a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0x37c6ed13
    * @param _hashId of the Standard Content Token.
    * @return uint96 releaseVal of a Standard Content Token.
    */
    function returnSContentTokenReleaseVal(
        bytes32 _hashId
    ) internal view returns(uint96) {
        return s_sContentTokenSearch[_hashId].releaseVal;
    }

    /**
    * @notice Retrieves enabled and disabled 3-bit functional flag states of a Standard Content Token
    * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
    *      Function Selector: 0xe11626bf
    * @param _hashId of the Standard Content Token.
    * @return uint256 bitVal of a Standard Content Token.
    */
    function returnSContentTokenBitVal(
        bytes32 _hashId
    ) internal view returns(uint256) {
        return s_sContentTokenSearch[_hashId].bitVal;
    }

    /**
    * @notice Retrieves a price map associated to a Content Collective Token.
    * @dev Returns data in 's_contentPriceMap' from 'ContentTokenPriceMapStorage.sol'.
    *      Function Selector: 0x6e8796cf
    * @param _hashId of the Collective Content Token.
    * @return uint256 _priceMap associated to a Content Collective Token
    */
    function returnContentTokenPriceMap(
        bytes32 _hashId
    ) internal view returns(uint256 _priceMap) {
        return s_contentTokenPriceMap[_hashId];
    }

    /**
    * @notice Retrieves property data of a Variant Content Token.
    * @dev Returns data in 's_variantSearch' from 'VariantMapStorage.sol'.
    *      Function Selector: 0x0a52a993
    * @param _hashId of the Variant Content Token.
    * @return Variants struct defining the data of the Variant Content Token.
    */
    function returnVariantSearch(
        bytes32 _hashId
    ) internal view returns(Variants memory) {
        return s_variantSearch[_hashId];
    }

    /**
    * @notice Retrieves raw values associated to the cost of obtaining a Variant Content Token.
    * @dev Returns data in 's_variantMap' from 'VariantMapStorage.sol'.
    *      Function Selector: 0x062103c8
    * @param _hashId of the Variant Content Token.
    * @return uint256 _rMap containing numerical values related to obtaining the asset.
    */
    function returnVariantMap(
        bytes32 _hashId
    ) internal view returns(uint256 _rMap) {
        return s_variantMap[_hashId];
    }

    /**
    * @notice Retrieves the hash of alternative Content Token versions, relative to the original. 
    * @dev Returns data in 's_contentVersion' from 'VersionStemStorage.sol'.
    *      Function Selector: 0x797e67f7
    * @param _hashId of the Content Token version.
    * @param _versionIndex an incremental count used to identify derivatives of a Content Token.
    * @return bytes32 _versionHash associated to the _versionIndex.
    */
    function returnContentVersion(
        bytes32 _hashId,
        uint8 _versionIndex
    ) internal view returns(bytes32 _versionHash) {
        _versionHash = s_contentVersion[_hashId][_versionIndex];
        return _versionHash;
    }

    /**
    * @notice Retrieves a defined total of token-specific STEM track indexes.
    * @dev Returns data in 's_stemTracks' from 'VersionStemStorage.sol'.
    *      Function Selector: 0xcfdcac74
    * @param _hashId of the Content Token version.
    * @return uint8 _stemTracks defined in relation to a Content Token.
    */
    function returnStemTracks(
        bytes32 _hashId
    ) internal view returns(uint8 _stemTracks) { 
        return s_stemTracks[_hashId];
    }

    /**
    * @notice Retrieves association data between two Content Tokens.
    * @dev Returns data in 's_inAssociation from 'InAssociationStorage.sol'.
    *      Function Selector: 0x73f7883d
    * @param _hashId of the Content Token version.
    * @param _associationIndex an incremental index for defining groupings of tokens published in different contexts and times.
    * @return bytes32 _associatedHash grouped with the _hashId value.
    */
    function returnInAssociation(
        bytes32 _hashId,
        uint32 _associationIndex
    ) internal view returns(bytes32 _associatedHash) {
        _associatedHash = s_InAssociation[_hashId][_associationIndex];
        return _associatedHash;
    }


        /**
    * @notice Retrieves association data between two Content Tokens.
    * @dev Returns data in 's_inAssociation from 'InAssociationStorage.sol'.
    *      Function Selector: 0x5f379ad8
    * @param _hashId of the Content Token version.
    * @param _associationIndex an incremental index for defining groupings of tokens published in different contexts and times.
    * @return bytes32 _associatedHash grouped with the _hashId value.
    */
    function returnCollaborators(
        bytes32 _hashId
    ) internal view returns(Collaborator memory) {
        return s_collaborators[_hashId];
    }

}
