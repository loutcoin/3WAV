// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

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

library LibPublishCContentTokenSearch {
    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );
    /*function _publishCContentTokenSearch(
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint32 _cPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint96 _cReleaseVal
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        ContentTokenSearchStruct.s_cContentTokenSearch[
            _hashId
        ] = CContentTokenStorage.CContentToken({
            numToken: _numToken,
            cSupplyVal: _cSupplyVal,
            sPriceUsdVal: _sPriceUsdVal,
            cPriceUsdVal: _cPriceUsdVal,
            sSupplyVal: _sSupplyVal,
            sReserveVal: _sReserveVal,
            cReleaseVal: _cReleaseVal
        });
    }*/

    // This is literally an identical copy of that in 'LibPublishCContentTokenSearchBatch',
    // Should just be placed in a library and used in both of these helper libraries
    /* function _publishCContentTokenSearchHelper(
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken;

        ContentTokenSearchStruct.s_cContentTokenSearch[
            _hashId
        ] = CContentTokenStorage.CContentToken({
            numToken: _cCTKN.numToken,
            cSupplyVal: _cCTKN.cSupplyVal,
            sPriceUsdVal: _cCTKN.sPriceUsdVal,
            cPriceUsdVal: _cCTKN.cPriceUsdVal,
            sSupplyVal: _cCTKN.sSupplyVal,
            sReserveVal: _cCTKN.sReserveVal,
            cReleaseVal: _cCTKN.cReleaseVal
        });
    }*/

    /*function _publishCContentTokenStackTest(
        address _creatorId,
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken,
        CollaboratorStructStorage.Collaborator calldata _collaborator
    ) internal {
        {
            _publishCContentTokenSearch(_hashId, _cContentToken);
        }
        {
            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _cContentToken.numToken
            );
        }

        if (_collaborator.numCollaborator != 0) {
            LibPublishContentTokenCollaboratorMap
                ._publishContentTokenCollaboratorMap(_hashId, _collaborator);
        }
        emit CContentTokenPublished(
            _creatorId,
            _hashId,
            _cContentToken.numToken
        );
    }*/

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
        emit CContentTokenPublished(
            _creatorTokenVariant.creatorToken.creatorId,
            _creatorTokenVariant.creatorToken.hashId,
            _cContentToken.numToken
        );
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
        emit CContentTokenPublished(
            _creatorToken.creatorId,
            _creatorToken.hashId,
            _cContentToken.numToken
        );
    }
}
