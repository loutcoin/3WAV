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

library LibPublishSContentTokenWavSupplies {
    error PublishSContentToken__LengthMismatch();
    /*
     * @notice Publishes the remaining supply data of a SContentToken.
     * @dev Writes and stores the remaining supply data of two or more CContentToken Variants on the blockchain.
     * @param _hashId Identifier of Content Token being queried.
     * @param _cSupplyVal Collection supply property.
     */
    /*function _publishSContentTokenWavSupplies(
        bytes32 _hashId,
        uint112 _cSupplyVal
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _hashId
        ] = LibPublishCWavSuppliesHelper.publishCWavSuppliesHelper(_cSupplyVal);
    }*/

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
