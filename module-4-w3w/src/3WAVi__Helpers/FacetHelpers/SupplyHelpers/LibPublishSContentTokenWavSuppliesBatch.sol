// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {
    LibPublishCWavSuppliesHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCWavSuppliesHelper.sol";

import {
    SContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

library LibPublishSContentTokenWavSuppliesBatch {
    error PublishSContentTokenBatch__LengthMismatch();
    /*function _publishSContentTokenWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        uint112[] memory _cSupplyValBatch
    ) internal {
        uint256 _hashLength = _hashIdBatch.length;
        if (_hashLength < 2 || _cSupplyValBatch.length != _hashLength)
            revert PublishSContentTokenBatch__LengthMismatch();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _hashLength; ) {
            uint112 _cSupplyVal = _cSupplyValBatch[i];

            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashIdBatch[i]
            ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                _cSupplyVal
            );

            unchecked {
                ++i;
            }
        }
    }*/

    /*function _publishSContentTokenWavSuppliesTest(
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken
    ) external {
        if (
            _hashIdBatch.length < 2 ||
            _sContentToken.length != _hashIdBatch.length
        ) revert PublishSContentTokenBatch__LengthMismatch();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            uint112 _supplyVal = _sContentToken[i].supplyVal;
            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashIdBatch[i]
            ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
                _supplyVal
            );

            unchecked {
                ++i;
            }
        }
    }*/

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
