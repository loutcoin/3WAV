// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CollaboratorStructStorage
} from "../../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    LibPublishCreatorToken
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCreatorToken.sol";

import {
    LibPublishContentTokenCollaboratorMap
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishContentTokenCollaboratorMap.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    LibPublishCContentTokenSearchHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCContentTokenSearchHelper.sol";

library LibPublishCContentTokenSearch {
    function _publishCContentTokenVariantSearch(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) internal {
        {
            LibPublishCContentTokenSearchHelper
                ._publishCContentTokenSearchHelper(
                    _creatorTokenVariant.creatorToken.hashId,
                    _cContentToken
                );
        }
        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorTokenVariant.creatorToken.creatorId,
                _creatorTokenVariant.creatorToken.hashId,
                _cContentToken.numToken
            );
        }

        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(
                    _creatorTokenVariant.creatorToken.hashId,
                    _collaborator
                );
        }
    }

    function _publishCContentTokenSearch(
        CreatorTokenStorage.CreatorToken calldata _creatorToken,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) internal {
        {
            LibPublishCContentTokenSearchHelper
                ._publishCContentTokenSearchHelper(
                    _creatorToken.hashId,
                    _cContentToken
                );
        }
        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorToken.creatorId,
                _creatorToken.hashId,
                _cContentToken.numToken
            );
        }

        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(
                    _creatorToken.hashId,
                    _collaborator
                );
        }
    }
}
