// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

library ReturnContentToken {
    /**
     * @notice Retrieves explict property values of a Content Collective Token.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xf5e22195
     * @param _hashId Identifier of Content Token being queried.
     * @return CContentToken associated to the hashId.
     */
    function returnCContentTokenSearch(
        bytes32 _hashId
    ) internal view returns (CContentTokenStorage.CContentToken memory) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return ContentTokenSearchStruct.s_cContentTokenSearch[_hashId];
    }

    /**
     * @notice Retrieves the number of tokens compromising a Content Collective Token.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xc17d5286
     * @param _hashId Identifier of Content Token being queried.
     * @return uint16 numToken of a Content Collective Token.
     */
    function returnCContentTokenNumToken(
        bytes32 _hashId
    ) internal view returns (uint16) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return ContentTokenSearchStruct.s_cContentTokenSearch[_hashId].numToken;
    }

    /**
     * @notice Retrieves core USD price definition of a Content Collective Token entity.
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x929b1943
     * @param _hashId Identifier of Content Token being queried.
     * @return uint32 cPriceUsdVal of a Content Collective Token.
     */
    function returnCContentTokenCPriceUsdVal(
        bytes32 _hashId
    ) internal view returns (uint32) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cPriceUsdVal;
    }

    /**
     * @notice Retrieves seperate supply definitions of members within a Content Collective Token.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x862b255f
     * @param _hashId Identifier of Content Token being queried.
     * @return uint112 sSupplyVal of a Content Collective Token.
     */
    function returnCContentTokenSPriceUsdVal(
        bytes32 _hashId
    ) internal view returns (uint112) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .sPriceUsdVal;
    }

    /**
     * @notice Retrieves core supply definitions of a Content Collective Token entity.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x4119e1ec
     * @param _hashId Identifier of Content Token being queried.
     * @return uint112 cSupplyVal of a Content Collective Token.
     */
    function returnCContentTokenCSupplyVal(
        bytes32 _hashId
    ) internal view returns (uint112) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_cContentTokenSearch[_hashId].cSupplyVal;
    }

    /**
     * @notice Retrieves core total supply values of a Content Collective Token entity.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x2349552f
     * @param _hashId Identifier of Content Token being queried.
     * @return uint224 cTotalSupplyVal of a Content Collective Token.
     */
    function returnCContentTokenSSupplyVal(
        bytes32 _hashId
    ) internal view returns (uint224) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_cContentTokenSearch[_hashId].sSupplyVal;
    }

    /**
     * @notice Retrieves core initial supply values of a Content Collective Token entity.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x47c3ae2c
     * @param _hashId Identifier of Content Token being queried.
     * @return sReserveVal The seperate sale reserve property of a CContentToken.
     */
    function returnCContentTokenSReserveVal(
        bytes32 _hashId
    ) internal view returns (uint160) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_cContentTokenSearch[_hashId].sReserveVal;
    }

    /**
     * @notice Retrieves core time-based sale properties of a Content Collective Token entity.
     * @dev Returns data in 's_cContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xfb42d534
     * @param _hashId Identifier of Content Token being queried.
     * @return uint96 releaseVal of a Content Collective Token.
     */
    function returnCContentTokenReleaseVal(
        bytes32 _hashId
    ) internal view returns (uint96) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_cContentTokenSearch[_hashId].cReleaseVal;
    }

    /**
     * @notice Retrieves explict property values of a Standard Content Token
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xf053e568
     * @param _hashId Identifier of Content Token being queried.
     * @return SContentToken associated to the hashId
     */
    function returnSContentTokenSearch(
        bytes32 _hashId
    ) internal view returns (SContentTokenStorage.SContentToken memory) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return ContentTokenSearchStruct.s_sContentTokenSearch[_hashId];
    }

    /**
     * @notice Retrieves the number of tokens compromising a Standard Content Token
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x9812b925
     * @param _hashId Identifier of Content Token being queried.
     * @return uint16 numToken of a Standard Content Token.
     */
    function returnSContentTokenNumToken(
        bytes32 _hashId
    ) internal view returns (uint16) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return ContentTokenSearchStruct.s_sContentTokenSearch[_hashId].numToken;
    }

    /**
     * @notice Retrieves the USD price definition of a Standard Content Token
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xf366cd7f
     * @param _hashId Identifier of Content Token being queried.
     * @return uint32 priceUsdVal of a Standard Content Token.
     */
    function returnSContentTokenPriceUsdVal(
        bytes32 _hashId
    ) internal view returns (uint32) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId].priceUsdVal;
    }

    /**
     * @notice Retrieves the raw supply definitions of a Standard Content Token
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0xf45af9d4
     * @param _hashId Identifier of Content Token being queried.
     * @return uint112 supplyVal of a Standard Content Token.
     */
    function returnSContentTokenSupplyVal(
        bytes32 _hashId
    ) internal view returns (uint112) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId].supplyVal;
    }

    /**
     * @notice Retrieves time-based sale properties of a Standard Content Token
     * @dev Returns data in 's_sContentTokenSearch' from 'ContentTokenSearchStorage.sol'.
     *      Function Selector: 0x37c6ed13
     * @param _hashId Identifier of Content Token being queried.
     * @return uint96 releaseVal of a Standard Content Token.
     */
    function returnSContentTokenReleaseVal(
        bytes32 _hashId
    ) internal view returns (uint96) {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        return
            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId].releaseVal;
    }
}
