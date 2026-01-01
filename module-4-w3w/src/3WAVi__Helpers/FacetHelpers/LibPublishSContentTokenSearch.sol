// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    LibPublishSContentTokenCollaboratorMap
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenCollaboratorMap.sol";

import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";

import {
    LibPublishSContentTokenSearchHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearchHelper.sol";

library LibPublishSContentTokenSearch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    function _publishSContentTokenVariantSearch(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator calldata _sCollaborator
    ) internal {
        bytes32 _hashId = _creatorTokenVariant.creatorToken.hashId;
        address _creatorId = _creatorTokenVariant.creatorToken.creatorId;

        {
            LibPublishSContentTokenSearchHelper
                ._publishSContentTokenSearchHelper(_hashId, _sContentToken);
        }

        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _sContentToken.numToken
            );
        }
        // ** Look back over
        if (_sCollaborator.numCollaborator != 0) {
            LibPublishSContentTokenCollaboratorMap
                ._publishSContentTokenCollaboratorMap(_hashId, _sCollaborator);
        }
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _sContentToken.numToken
        );
    }

    function _publishSContentTokenSearch(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator calldata _sCollaborator
    ) internal {
        bytes32 _hashId = _creatorToken.hashId;
        address _creatorId = _creatorToken.creatorId;

        {
            LibPublishSContentTokenSearchHelper
                ._publishSContentTokenSearchHelper(_hashId, _sContentToken);
        }

        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _sContentToken.numToken
            );
        }
        if (_sCollaborator.numCollaborator != 0) {
            // ** Look back over
            LibPublishSContentTokenCollaboratorMap
                ._publishSContentTokenCollaboratorMap(_hashId, _sCollaborator);
        }
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _sContentToken.numToken
        );
    }
}
