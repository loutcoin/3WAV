// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    LibPublishCWavSuppliesHelper
} from "../../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/PublishSupply/LibPublishCWavSuppliesHelper.sol";

import {
    SContentTokenStorage
} from "../../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

library LibPublishSContentTokenWavSuppliesBatch {
    error PublishSContentTokenBatch__LengthMismatch();

    function _publishSContentTokenVariantWavSuppliesBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken
    ) external {
        if (
            _sContentToken.length < 2 ||
            _sContentToken.length != _creatorTokenVariant.length
        ) revert PublishSContentTokenBatch__LengthMismatch();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _sContentToken.length; ) {
            uint112 _supplyVal = _sContentToken[i].supplyVal;
            bytes32 _hashId = _creatorTokenVariant[i].creatorToken.hashId;
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                _supplyVal
            );

            unchecked {
                ++i;
            }
        }
    }

    function _publishSContentTokenWavSuppliesBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        SContentTokenStorage.SContentToken[] calldata _sContentToken
    ) external {
        if (
            _sContentToken.length < 2 ||
            _sContentToken.length != _creatorToken.length
        ) revert PublishSContentTokenBatch__LengthMismatch();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _sContentToken.length; ) {
            uint112 _supplyVal = _sContentToken[i].supplyVal;
            bytes32 _hashId = _creatorToken[i].hashId;
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                _supplyVal
            );

            unchecked {
                ++i;
            }
        }
    }
}
