// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
/*import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";*/
/*import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";*/
import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";
/*import {
    CollaboratorMapStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";*/
/*import {
    LibPublishCreatorToken
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCreatorToken.sol";*/
import {
    LibPublishCContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSuppliesBatch.sol";
import {
    LibPublishCContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearchBatch.sol";
// **** We need to update the imports we no longer need like 50%+ of them ****
contract PublishCContentTokenBatch {
    event Test01(bool indexed _test1);
    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    event CContentTokenBatchPublished(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    error PublishCContentTokenBatch__LengthMismatch();
    error PublishCContentTokenBatch__NumInputInvalid();

    /** ****This was the original just commented out am optimizing the stack to avoid stack too deep
     * @notice Publishes a batch of two or more user-defined CContentTokens.
     * @dev Writes and stores the data of multiple CContentTokens on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _cContentToken.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert PublishCContentTokenBatch__LengthMismatch();

        // Storage locals
        /*ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();*/

    // *** Just Added this I believe all CContentTokens will need priceMap value
    // *** Look over PublishCVariantBatch for more.
    // We  need to update '_publishCContentTokenWavSupplies' I believe to incoporate _priceMapPages
    /*LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCKTN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCKTN.numToken;

            if (_numToken == 0 || _cCKTN.cSupplyVal == 0)
                revert PublishCContentTokenBatch__NumInputInvalid();

            /*ContentTokenSearchStruct.s_cContentTokenSearch[
                _hashId
            ] = CContentTokenStorage.CContentToken({
                numToken: _numToken,
                cSupplyVal: _cCKTN.cSupplyVal,
                sPriceUsdVal: _cCKTN.sPriceUsdVal,
                cPriceUsdVal: _cCKTN.cPriceUsdVal,
                sSupplyVal: _cCKTN.sSupplyVal,
                sReserveVal: _cCKTN.sReserveVal,
                cReleaseVal: _cCKTN.cReleaseVal
            });*/

    /*LibPublishCContentTokenSearchBatch._publishCContentTokenSearchBatch(
                _hashId,
                _cCKTN
            );

            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if (_collaborator.length > 0) {
                uint256 _royaltyMap = _royaltyMapBatch[i];
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                /*CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    CollaboratorMapStruct.s_collaborators[
                        _hashId
                    ] = CollaboratorStructStorage.Collaborator({
                        numCollaborator: _collab.numCollaborator,
                        royaltyVal: _collab.royaltyVal
                    });
                    CollaboratorMapStruct.s_royalties[
                        _hashId
                    ] = _royaltyMapBatch[i];
                    CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0)
                    revert PublishCContentTokenBatch__LengthMismatch();*/
    /*LibPublishCContentTokenCollaboratorMapBatch
                    ._publishCContentTokenCollaboratorMapBatch(
                        _hashId,
                        _collab,
                        _royaltyMap
                    );
            }

            emit CContentTokenPublished(_creatorId, _hashId, _numToken);

            unchecked {
                ++i;
            }
        }

        emit CContentTokenBatchPublished(_creatorId, uint16(_hashLength));
    }*/

    /* We're already looping and preforming ContentTokenSearchStruct and CollaboratorMap for each index of [i]
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     */

    /*
     * @notice Publishes a batch of two or more user-defined CContentTokens.
     * @dev Writes and stores the data of multiple CContentTokens on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    /*function publishCContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        //uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        //uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashIdBatch.length < 2 ||
            _cContentToken.length != _hashIdBatch.length ||
            _collaborator.length != _hashIdBatch.length
        ) revert PublishCContentTokenBatch__LengthMismatch();
        // _royaltyMapBatch.length != _hashIdBatch.length ||

        LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesTest(
                _hashIdBatch,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );

        LibPublishCContentTokenSearchBatch.publishStackTest(
            _creatorId,
            _hashIdBatch,
            _cContentToken,
            _collaborator
            //_royaltyMapBatch
        );

        emit CContentTokenBatchPublished(
            _creatorId,
            uint16(_hashIdBatch.length)
        );
    }*/

    /**
     * @notice Publishes a batch of two or more user-defined CContentTokens.
     * @dev Writes and stores the data of multiple CContentTokens on the blockchain.
     * @param _creatorToken Batch of user-defined CreatorToken structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCContentTokenBatch(
        CreatorTokenStorage.CreatorToken[] calldata _creatorToken,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesBatch(
                _creatorToken,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );
        emit Test01(true);
        // emits event also
        LibPublishCContentTokenSearchBatch._publishCContentTokenSearchBatch(
            _creatorToken,
            _cContentToken,
            _collaborator
        );
    }

    /* FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSuppliesBatch
     * @notice Publishes remaining supply data of two or more CContentToken.
     * @dev Writes and stores remaining supply data of two or more CContentTokens on the blockchain.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of CContentToken structs
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCContentTokenWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint256 _hashLength = _hashIdBatch.length;

        uint256 _pageCursor = 0;
        uint256 _pricePageCursor = 0;

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCTKN.numToken;
            uint112 _cSupplyVal = _cCTKN.cSupplyVal;
            uint224 _sSupplyVal = _cCTKN.sSupplyVal;
            uint160 _sReserveVal = _cCTKN.sReserveVal;

            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = publishSWavSuppliesHelper(_sSupplyVal, _sReserveVal);

            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashId
            ] = publishCWavSuppliesHelper(_cSupplyVal);
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                1
            ] = _sWavSuppliesTier1;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                2
            ] = _sWavSuppliesTier2;
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
                3
            ] = _sWavSuppliesTier3;

            uint16 _pages = uint16((uint256(_numToken) + 63) >> 6);

            for (uint16 p = 0; p < _pages; ) {
                if (_pageCursor >= _tierMapPages.length) break;
                uint256 _tierPage = _tierMapPages[_pageCursor];
                if (_tierPage != 0) {
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        p
                    ] = _tierPage;
                }
                unchecked {
                    ++_pageCursor;
                    ++p;
                }
            }

            uint16 _pricePages = uint16((uint256(_numToken) + 127) >> 7);
            for (uint16 pp = 0; pp < _pricePages; ) {
                if (_pricePageCursor >= _priceMapPages.length) break;
                uint256 _pricePage = _priceMapPages[_pricePageCursor];
                if (_pricePage != 0) {
                    ContentTokenSupplyMapStruct.s_sPriceMap[_hashId][
                        pp
                    ] = _pricePage;
                }
                unchecked {
                    ++_pricePageCursor;
                    ++pp;
                }
            }
            unchecked {
                ++i;
            }
        }
    }*/
}
