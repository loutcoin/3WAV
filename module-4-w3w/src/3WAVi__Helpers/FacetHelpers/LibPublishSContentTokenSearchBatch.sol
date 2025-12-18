// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    LibPublishContentTokenCollaboratorMap
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishContentTokenCollaboratorMap.sol";

import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    LibPublishSContentTokenSearchHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearchHelper.sol";

library LibPublishSContentTokenSearchBatch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    error PublishSContentTokenBatch__NumInputInvalid();
    // This is literally an identical copy of that in 'LibPublishSContentTokenSearchBatch',
    // Should just be placed in a library and used in both of these helper libraries
    /*function _publishSContentTokenSearchBatch(
        bytes32 _hashId,
        SContentTokenStorage.SContentToken calldata _sContentToken
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken;

        ContentTokenSearchStruct.s_sContentTokenSearch[
            _hashId
        ] = SContentTokenStorage.SContentToken({
            numToken: _sCTKN.numToken,
            priceUsdVal: _sCTKN.priceUsdVal,
            supplyVal: _sCTKN.supplyVal,
            releaseVal: _sCTKN.releaseVal
        });
    }*/

    /*function _publishSContentStackTest(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
    ) internal {
        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCKTN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCKTN.numToken;

            if (_numToken == 0 || _sCKTN.supplyVal == 0)
                revert PublishSContentTokenBatch__NumInputInvalid();
            {
                _publishSContentTokenSearchBatch(_hashId, _sCKTN);
            }

            {
                LibPublishCreatorToken._publishCreatorToken(
                    _creatorId,
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
            emit SContentTokenPublished(_creatorId, _hashId, _numToken);

            unchecked {
                ++i;
            }
        }
    }*/

    function _publishSContentTokenVariantSearchBatch(
        // SHOULD possibly just be CreatorToken
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
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
            if (_collaborator.length > 0) {
                //uint256 _royaltyMap = _royaltyMapBatch[i];
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];

                {
                    LibPublishContentTokenCollaboratorMap
                        ._publishContentTokenCollaboratorMap(_hashId, _collab);
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
        // SHOULD possibly just be CreatorToken
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
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
            if (_collaborator.length > 0) {
                //uint256 _royaltyMap = _royaltyMapBatch[i];
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];

                {
                    LibPublishContentTokenCollaboratorMap
                        ._publishContentTokenCollaboratorMap(_hashId, _collab);
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
