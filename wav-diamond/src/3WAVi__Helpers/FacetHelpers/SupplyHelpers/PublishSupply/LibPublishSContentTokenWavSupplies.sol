// SPDX-License-Identifier: UNLICENSED
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

library LibPublishSContentTokenWavSupplies {
    error PublishSContentToken__LengthMismatch();

    /**
     * @notice Publishes the remaining supply data of a SContentToken Variant.
     * @dev Writes and stores the remaining supply data of a SContentToken Variant on the blockchain.
     * @param _creatorTokenVariant User-defined creatorTokenVariant struct.
     * @param _sContentToken User-defined sContentToken struct.
     */
    function _publishSContentTokenVariantWavSupplies(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken calldata _sContentToken
    ) external {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _creatorTokenVariant.creatorToken.hashId
        ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
            _sContentToken.supplyVal
        );
    }

    /**
     * @notice Publishes the remaining supply data of a SContentToken.
     * @dev Writes and stores the remaining supply data of a SContentToken on the blockchain.
     * @param _creatorToken User-defined creatorToken struct.
     * @param _sContentToken User-defined sContentToken struct.
     */
    function _publishSContentTokenWavSupplies(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        SContentTokenStorage.SContentToken calldata _sContentToken
    ) external {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _creatorToken.hashId
        ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(
            _sContentToken.supplyVal
        );
    }
}
