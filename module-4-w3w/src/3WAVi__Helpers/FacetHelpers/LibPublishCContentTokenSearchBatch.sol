// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";

import {
    LibPublishContentTokenCollaboratorMap
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishContentTokenCollaboratorMap.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    LibPublishCContentTokenSearchHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearchHelper.sol";

library LibPublishCContentTokenSearchBatch {
    error PublishCContentTokenBatch__NumInputInvalid();

    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    function _publishCContentTokenVariantSearchBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
    ) internal {
        for (uint256 i = 0; i < _cContentToken.length; ) {
            bytes32 _hashId = _creatorTokenVariant[i].creatorToken.hashId;
            CContentTokenStorage.CContentToken calldata _cCKTN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCKTN.numToken;

            if (_numToken == 0 || _cCKTN.cSupplyVal == 0)
                revert PublishCContentTokenBatch__NumInputInvalid();
            {
                LibPublishCContentTokenSearchHelper
                    ._publishCContentTokenSearchHelper(_hashId, _cCKTN);
            }

            {
                LibPublishCreatorToken._publishCreatorToken(
                    _creatorTokenVariant[i].creatorToken.creatorId,
                    _hashId,
                    _numToken
                );
            }

            if (_collaborator.length > 0) {
                //uint256 _royaltyMap = _royaltyMapBatch[i];
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];

                {
                    LibPublishContentTokenCollaboratorMap
                        ._publishContentTokenCollaboratorMap(_hashId, _collab);
                }
            }
            emit CContentTokenPublished(
                _creatorTokenVariant[i].creatorToken.creatorId,
                _hashId,
                _numToken
            );

            unchecked {
                ++i;
            }
        }
    }

    function _publishCContentTokenSearchBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
    ) internal {
        for (uint256 i = 0; i < _cContentToken.length; ) {
            bytes32 _hashId = _creatorToken[i].hashId;
            CContentTokenStorage.CContentToken calldata _cCKTN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCKTN.numToken;

            if (_numToken == 0 || _cCKTN.cSupplyVal == 0)
                revert PublishCContentTokenBatch__NumInputInvalid();
            {
                LibPublishCContentTokenSearchHelper
                    ._publishCContentTokenSearchHelper(_hashId, _cCKTN);
            }

            {
                LibPublishCreatorToken._publishCreatorToken(
                    _creatorToken[i].creatorId,
                    _hashId,
                    _numToken
                );
            }

            if (_collaborator.length > 0) {
                //uint256 _royaltyMap = _royaltyMapBatch[i];
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];

                {
                    LibPublishContentTokenCollaboratorMap
                        ._publishContentTokenCollaboratorMap(_hashId, _collab);
                }
            }
            emit CContentTokenPublished(
                _creatorToken[i].creatorId,
                _hashId,
                _numToken
            );

            unchecked {
                ++i;
            }
        }
    }
}
