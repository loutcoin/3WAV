// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {
    LibPublishSWavSuppliesHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSWavSuppliesHelper.sol";

import {
    LibPublishCWavSuppliesHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCWavSuppliesHelper.sol";

import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

library LibPublishCContentTokenWavSuppliesBatch {
    /*
     * @notice Publishes remaining supply data of two or more CContentToken.
     * @dev Writes and stores remaining supply data of two or more CContentTokens on the blockchain.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of CContentToken structs
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function _publishCContentTokenWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint256 _pageCursor = 0;
        uint256 _pricePageCursor = 0;

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCTKN.numToken;
            uint112 _cSupplyVal = _cCTKN.cSupplyVal;
            uint224 _sSupplyVal = _cCTKN.sSupplyVal;
            uint160 _sReserveVal = _cCTKN.sReserveVal;

            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                    _sSupplyVal,
                    _sReserveVal
                );

            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishSWavSuppliesHelper.publishCWavSuppliesHelper(
                _cSupplyVal
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

            uint16 _pages = uint16((uint256(_numToken) + 63) >> 6);

            for (uint16 p = 0; p < _pages; ) {
                if (_pageCursor >= _tierMapPages.length) break;
                uint256 _tierPage = _tierMapPages[_pageCursor];
                if (_tierPage != 0) {
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        p
                    ] = _tierPage;
                }
                unchecked {
                    ++_pageCursor;
                    ++p;
                }
            }

            uint16 _pricePages = uint16((uint256(_numToken) + 127) >> 7);
            for (uint16 pp = 0; pp < _pricePages; ) {
                if (_pricePageCursor >= _priceMapPages.length) break;
                uint256 _pricePage = _priceMapPages[_pricePageCursor];
                if (_pricePage != 0) {
                    ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][
                        pp
                    ] = _pricePage;
                }
                unchecked {
                    ++_pricePageCursor;
                    ++pp;
                }
            }
            unchecked {
                ++i;
            }
        }
    }*/

    /*function _publishCContentTokenWavSuppliesTest(
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            {
                ContentTokenSupplyMapStruct.s_cWavSupplies[
                    _hashId
                ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                    _cCTKN.cSupplyVal
                );

                (
                    uint112 _sWavSuppliesTier1,
                    uint112 _sWavSuppliesTier2,
                    uint112 _sWavSuppliesTier3
                ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                        _cCTKN.sSupplyVal,
                        _cCTKN.sReserveVal
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
                    (uint256(_cCTKN.numToken) + 63) >> 6
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
                    (uint256(_cCTKN.numToken) + 127) >> 7
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
    }*/

    function _publishCContentTokenWavSuppliesBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _cContentToken.length; ) {
            bytes32 _hashId = _creatorToken[i].hashId;
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            {
                ContentTokenSupplyMapStruct.s_cWavSupplies[
                    _hashId
                ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                    _cCTKN.cSupplyVal
                );

                (
                    uint112 _sWavSuppliesTier1,
                    uint112 _sWavSuppliesTier2,
                    uint112 _sWavSuppliesTier3
                ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                        _cCTKN.sSupplyVal,
                        _cCTKN.sReserveVal
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
                    (uint256(_cCTKN.numToken) + 63) >> 6
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
                    (uint256(_cCTKN.numToken) + 127) >> 7
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
            unchecked {
                ++i;
            }
        }
    }

    function _publishCContentTokenVariantWavSuppliesBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _cContentToken.length; ) {
            bytes32 _hashId = _creatorTokenVariant[i].creatorToken.hashId;
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            {
                ContentTokenSupplyMapStruct.s_cWavSupplies[
                    _hashId
                ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                    _cCTKN.cSupplyVal
                );

                (
                    uint112 _sWavSuppliesTier1,
                    uint112 _sWavSuppliesTier2,
                    uint112 _sWavSuppliesTier3
                ) = LibPublishSWavSuppliesHelper.publishSWavSuppliesHelper(
                        _cCTKN.sSupplyVal,
                        _cCTKN.sReserveVal
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
                    (uint256(_cCTKN.numToken) + 63) >> 6
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
                    (uint256(_cCTKN.numToken) + 127) >> 7
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
            unchecked {
                ++i;
            }
        }
    }

    /*function publishPages(
        uint256 _pageCursor,
        uint256 _pricePageCursor,
        uint256[] _tierMapPages
    ) internal {}*/

    /*function publishTierPages(
        bytes32 _hashId,
        uint16 _numToken,
        uint256[] calldata _tierMapPages
    ) internal {
        uint256 _pageCursor = 0;
        uint16 _pages = uint16((uint256(_numToken) + 63) >> 6);
        for (uint16 p = 0; p < _pages; ) {
            if (_pageCursor >= _tierMapPages.length) break;
            uint256 _tierPage = _tierMapPages[_pageCursor];
            if (_tierPage != 0) {
                //ContentTokenSupplyMapStruct.s_tierMap[_hashId][p] = _tierPage;
            }
            unchecked {
                ++_pageCursor;
                ++p;
            }
        }
    }*/
}
