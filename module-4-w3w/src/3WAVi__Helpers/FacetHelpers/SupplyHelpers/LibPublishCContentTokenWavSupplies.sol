// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {
    LibPublishSWavSuppliesHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSWavSuppliesHelper.sol";

import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

library LibPublishCContentTokenWavSupplies {
    /*
     * @notice Publishes the remaining supply data of or more CContentTokens.
     * @dev Writes and stores the remaining supply data of two or more CContentToken on the blockchain.
     * @param _hashId Identifier of Content Token being queried.
     * @param _cSupplyVal Collection supply property.
     * @param _sSupplyVal Seperate sale supply property.
     * @param _sReserveVal Seperate sale reserve property.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function _publishCContentTokenWavSupplies(
        bytes32 _hashId,
        uint112 _cSupplyVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint256[] calldata _tierMapPages //uint256[] calldata _stateMapPages,
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        (
            uint112 _sWavSuppliesTier1,
            uint112 _sWavSuppliesTier2,
            uint112 _sWavSuppliesTier3
        ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                _sSupplyVal,
                _sReserveVal
            );

        // Encode and store each tier
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _hashId
        ] = LibPublishSWavSuppliesHelper.publishCWavSuppliesHelper(_cSupplyVal);
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            1
        ] = _sWavSuppliesTier1;
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            2
        ] = _sWavSuppliesTier2;
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            3
        ] = _sWavSuppliesTier3;

        uint256 _maxLength = _tierMapPages.length;

        for (uint256 i = 0; i < _maxLength; ) {
            if (i < _maxLength) {
                uint256 _tierPages = _tierMapPages[i];
                if (_tierPages != 0) {
                    // [uint16[i]]??
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        uint16(i)
                    ] = _tierPages;
                }
            }
            unchecked {
                ++i;
            }
        }
    }*/

    /*function _publishCContentTokenWavSuppliesTest(
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken;
        {
            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                    _cCTKN.sSupplyVal,
                    _cCTKN.sReserveVal
                );

            // Encode and store each tier
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishSWavSuppliesHelper.publishCWavSuppliesHelper(
                _cCTKN.cSupplyVal
            );
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                1
            ] = _sWavSuppliesTier1;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                2
            ] = _sWavSuppliesTier2;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                3
            ] = _sWavSuppliesTier3;
        }

        {
            uint16 _tierPages = uint16((uint256(_cCTKN.numToken) + 63) >> 6);
            uint256 _supplyPageCursor;
            for (uint16 p = 0; p < _tierPages; ) {
                if (_supplyPageCursor >= _tierMapPages.length) break;
                uint256 _tierPage = _tierMapPages[_supplyPageCursor];
                if (_tierPage != 0) {
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        p
                    ] = _tierPage;
                }
                unchecked {
                    ++_supplyPageCursor;
                    ++p;
                }
            }
        }

        {
            uint16 _pricePages = uint16((uint256(_cCTKN.numToken) + 127) >> 7);
            uint256 _pricePageCursor;
            for (uint16 pp = 0; pp < _pricePages; ) {
                if (_pricePageCursor >= _priceMapPages.length) break;
                uint256 _priceMapPage = _priceMapPages[_pricePageCursor];
                if (_pricePages != 0) {
                    ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][
                        pp
                    ] = _priceMapPage;
                }
                unchecked {
                    ++_pricePageCursor;
                    ++pp;
                }
            }
        }
    }*/

    function _publishCContentTokenVariantWavSupplies(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        bytes32 _hashId = _creatorTokenVariant.creatorToken.hashId;
        {
            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                    _cContentToken.sSupplyVal,
                    _cContentToken.sReserveVal
                );

            // Encode and store each tier
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishSWavSuppliesHelper.publishCWavSuppliesHelper(
                _cContentToken.cSupplyVal
            );
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                1
            ] = _sWavSuppliesTier1;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                2
            ] = _sWavSuppliesTier2;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                3
            ] = _sWavSuppliesTier3;
        }

        {
            uint16 _tierPages = uint16(
                (uint256(_cContentToken.numToken) + 63) >> 6
            );
            uint256 _supplyPageCursor;
            for (uint16 p = 0; p < _tierPages; ) {
                if (_supplyPageCursor >= _tierMapPages.length) break;
                uint256 _tierPage = _tierMapPages[_supplyPageCursor];
                if (_tierPage != 0) {
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        p
                    ] = _tierPage;
                }
                unchecked {
                    ++_supplyPageCursor;
                    ++p;
                }
            }
        }

        {
            uint16 _pricePages = uint16(
                (uint256(_cContentToken.numToken) + 127) >> 7
            );
            uint256 _pricePageCursor;
            for (uint16 pp = 0; pp < _pricePages; ) {
                if (_pricePageCursor >= _priceMapPages.length) break;
                uint256 _priceMapPage = _priceMapPages[_pricePageCursor];
                if (_pricePages != 0) {
                    ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][
                        pp
                    ] = _priceMapPage;
                }
                unchecked {
                    ++_pricePageCursor;
                    ++pp;
                }
            }
        }
    }

    function _publishCContentTokenWavSupplies(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        bytes32 _hashId = _creatorToken.hashId;
        {
            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                    _cContentToken.sSupplyVal,
                    _cContentToken.sReserveVal
                );

            // Encode and store each tier
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishSWavSuppliesHelper.publishCWavSuppliesHelper(
                _cContentToken.cSupplyVal
            );
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                1
            ] = _sWavSuppliesTier1;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                2
            ] = _sWavSuppliesTier2;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                3
            ] = _sWavSuppliesTier3;
        }

        {
            uint16 _tierPages = uint16(
                (uint256(_cContentToken.numToken) + 63) >> 6
            );
            uint256 _supplyPageCursor;
            for (uint16 p = 0; p < _tierPages; ) {
                if (_supplyPageCursor >= _tierMapPages.length) break;
                uint256 _tierPage = _tierMapPages[_supplyPageCursor];
                if (_tierPage != 0) {
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        p
                    ] = _tierPage;
                }
                unchecked {
                    ++_supplyPageCursor;
                    ++p;
                }
            }
        }

        {
            uint16 _pricePages = uint16(
                (uint256(_cContentToken.numToken) + 127) >> 7
            );
            uint256 _pricePageCursor;
            for (uint16 pp = 0; pp < _pricePages; ) {
                if (_pricePageCursor >= _priceMapPages.length) break;
                uint256 _priceMapPage = _priceMapPages[_pricePageCursor];
                if (_pricePages != 0) {
                    ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][
                        pp
                    ] = _priceMapPage;
                }
                unchecked {
                    ++_pricePageCursor;
                    ++pp;
                }
            }
        }
    }
}
