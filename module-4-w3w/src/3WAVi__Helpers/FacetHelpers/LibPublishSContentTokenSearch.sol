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
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    LibPublishContentTokenCollaboratorMap
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishContentTokenCollaboratorMap.sol";

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

    /*function _publishSContentTokenSearch(
        bytes32 _hashId,
        uint32 _cPriceUsdVal,
        uint112 _cSupplyVal,
        uint96 _cReleaseVal
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        /*SContentTokenStorage.SContentToken calldata

        ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
            });*/
    /*}*/

    /*function _publishSContentTokenSearchHelper(
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

    /*function _publishSContentTokenSearchTest(
        address _creatorId,
        bytes32 _hashId,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) internal {
        {
            _publishSContentTokenSearch(_hashId, _sContentToken);
        }

        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _sContentToken.numToken
            );
        }
        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(_hashId, _collaborator);
        }
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _sContentToken.numToken
        );
    }*/

    function _publishSContentTokenVariantSearch(
        CreatorTokenVariantStorage.CreatorTokenVariant calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken calldata _sContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
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
        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(_hashId, _collaborator);
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
        CollaboratorStructStorage.Collaborator calldata _collaborator
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
        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(_hashId, _collaborator);
        }
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _sContentToken.numToken
        );
    }
}
