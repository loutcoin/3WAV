// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    LibPublishSWavSuppliesHelper
} from "../../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishSWavSuppliesHelper.sol";

import {
    CContentTokenStorage
} from "../../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

library LibPublishCContentTokenWavSupplies {
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
