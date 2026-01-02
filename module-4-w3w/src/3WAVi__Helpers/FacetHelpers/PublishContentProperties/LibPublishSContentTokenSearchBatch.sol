// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    SContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    LibPublishSContentTokenCollaboratorMap
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenCollaboratorMap.sol";

import {
    LibPublishCreatorToken
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishCreatorToken.sol";

import {
    CreatorTokenVariantStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    LibPublishSContentTokenSearchHelper
} from "../../../../src/3WAVi__Helpers/FacetHelpers/PublishContentProperties/LibPublishSContentTokenSearchHelper.sol";

library LibPublishSContentTokenSearchBatch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    error PublishSContentTokenBatch__NumInputInvalid();

    function _publishSContentTokenVariantSearchBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator[] calldata _sCollaborator
    ) internal {
        for (uint256 i = 0; i < _sContentToken.length; ) {
            bytes32 _hashId = _creatorTokenVariant[i].creatorToken.hashId;
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];

            if (_sCTKN.numToken == 0 || _sCTKN.supplyVal == 0)
                revert PublishSContentTokenBatch__NumInputInvalid();
            {
                LibPublishSContentTokenSearchHelper
                    ._publishSContentTokenSearchHelper(_hashId, _sCTKN);
            }

            {
                LibPublishCreatorToken._publishCreatorToken(
                    _creatorTokenVariant[i].creatorToken.creatorId,
                    _hashId,
                    _sCTKN.numToken
                );
            }
            if (_sCollaborator.length > 0) {
                SCollaboratorStructStorage.SCollaborator
                    calldata _sCollab = _sCollaborator[i];

                {
                    LibPublishSContentTokenCollaboratorMap
                        ._publishSContentTokenCollaboratorMap(
                            _hashId,
                            _sCollab
                        );
                }
            }
            emit SContentTokenPublished(
                _creatorTokenVariant[i].creatorToken.creatorId,
                _hashId,
                _sCTKN.numToken
            );

            unchecked {
                ++i;
            }
        }
    }

    function _publishSContentTokenSearchBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        SCollaboratorStructStorage.SCollaborator[] calldata _sCollaborator
    ) internal {
        for (uint256 i = 0; i < _sContentToken.length; ) {
            bytes32 _hashId = _creatorToken[i].hashId;
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];

            if (_sCTKN.numToken == 0 || _sCTKN.supplyVal == 0)
                revert PublishSContentTokenBatch__NumInputInvalid();
            {
                LibPublishSContentTokenSearchHelper
                    ._publishSContentTokenSearchHelper(_hashId, _sCTKN);
            }

            {
                LibPublishCreatorToken._publishCreatorToken(
                    _creatorToken[i].creatorId,
                    _hashId,
                    _sCTKN.numToken
                );
            }
            if (_sCollaborator.length > 0) {
                SCollaboratorStructStorage.SCollaborator
                    calldata _sCollab = _sCollaborator[i];

                {
                    LibPublishSContentTokenCollaboratorMap
                        ._publishSContentTokenCollaboratorMap(
                            _hashId,
                            _sCollab
                        );
                }
            }
            emit SContentTokenPublished(
                _creatorToken[i].creatorId,
                _hashId,
                _sCTKN.numToken
            );

            unchecked {
                ++i;
            }
        }
    }
}
