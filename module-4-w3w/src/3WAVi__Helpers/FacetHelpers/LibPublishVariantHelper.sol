// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";

library LibPublishVariantHelper {
    error LibPublishVariantHelper__IndexIssue();

    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    function _publishVariantHelper(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant
    ) internal {
        AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();
        uint16 _variantIndex = _creatorTokenVariant.variantIndex;
        bytes32 _baseHashId = _creatorTokenVariant.baseHashId;
        if (_variantIndex == 0) revert LibPublishVariantHelper__IndexIssue();
        AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _creatorTokenVariant.creatorToken.hashId;
        AssociatedContentStruct.s_variantSearch[
            _creatorTokenVariant.creatorToken.hashId
        ] = _baseHashId;

        emit SVariantPublished(
            _creatorTokenVariant.creatorToken.creatorId,
            _creatorTokenVariant.creatorToken.hashId,
            _baseHashId,
            _variantIndex
        );
    } // bytes32 _hashId = _creatorTokenVariant.creatorToken.hashId[i];
}
