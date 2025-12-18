// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
/*import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";*/
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
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishVariantHelper.sol";
import {
    LibPublishCContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishCContentTokenWavSuppliesBatch.sol";
/*import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";*/

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    LibPublishCContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearchBatch.sol";

import {
    LibPublishCContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishCContentTokenSearch.sol";

contract PublishCVariantBatch {
    event CVariantPublished(
        address indexed creatorId,
        bytes32 indexed baseHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    event CContentTokenBatchPublished(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    error PublishCVariantBatch__LengthMismatch();
    error PublishCVariantBatch__NumInputInvalid();
    error PublishCVariantBatch__IndexIssue();

    /*
     * @notice Publishes a single SContentToken alongside two or more CContentToken Variants.
     * @dev Writes and stores the data of multiple CContentTokens, including one or more CContentToken Variants, on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _variantIndexBatch Batch of numerical indexes correlating to the total Variants of a base Content Token.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCContentTokenVariantBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] calldata _variantIndexBatch,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();
        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _cContentToken.length != _hashLength ||
            _variantIndexBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert PublishCVariantBatch__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();

        LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCTKN.numToken;

            if (_numToken == 0 || _cCTKN.cSupplyVal == 0)
                revert PublishCVariantBatch__NumInputInvalid();

            ContentTokenSearchStruct.s_cContentTokenSearch[
                _hashId
            ] = CContentTokenStorage.CContentToken({
                numToken: _numToken,
                cSupplyVal: _cCTKN.cSupplyVal,
                sPriceUsdVal: _cCTKN.sPriceUsdVal,
                cPriceUsdVal: _cCTKN.cPriceUsdVal,
                sSupplyVal: _cCTKN.sSupplyVal,
                sReserveVal: _cCTKN.sReserveVal,
                cReleaseVal: _cCTKN.cReleaseVal
            });

            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
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
                    revert PublishCVariantBatch__LengthMismatch();
            }

            if (i == 0) {
                emit CContentTokenPublished(_creatorId, _hashId, _numToken);
            } else {
                uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0)
                    revert PublishCVariantBatch__IndexIssue();
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][
                    _variantIndex
                ] = _hashId;
                AssociatedContentStruct.s_variantSearch[_hashId] = _hashIdBatch[
                    0
                ];

                emit CVariantPublished(
                    _creatorId,
                    _hashIdBatch[0],
                    _hashId,
                    _variantIndex
                );
            }

            unchecked {
                ++i;
            }
        }
        emit CContentTokenBatchPublished(_creatorId, uint16(_hashLength));
    }*/

    /* **** JUST ADDED _priceMapPages into this function we may need to look over other publish functions ****
     * @notice Publishes two or more CContentToken Variants.
     * @dev Writes and stores the data of two or more CContentToken Variants on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _baseHashIdBatch The Content Token associated to a derivative Variant.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _variantIndexBatch Batch of numerical indexes correlating to the total Variants of a base Content Token.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    /*function publishCVariantBatch(
        address _creatorId,
        bytes32[] calldata _baseHashIdBatch,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] calldata _variantIndexBatch,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _baseHashIdBatch.length != _hashLength ||
            _cContentToken.length != _hashLength ||
            _variantIndexBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert PublishCVariantBatch__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();

        // publishCContentTokenWavSuppliesBatch
        //uint256 _pageCursor = 0;

        LibPublishCContentTokenWavSuppliesBatch
            ._publishCContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _cContentToken,
                _tierMapPages,
                _priceMapPages
            );

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _baseHashId = _baseHashIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];
            //CContentTokenStorage.CContentToken calldata _cCTKN;
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCTKN.numToken;
            uint16 _variantIndex = _variantIndexBatch[i];

            if (_numToken == 0 || _cCTKN.cSupplyVal == 0 || _variantIndex == 0)
                revert PublishCVariantBatch__NumInputInvalid();

            ContentTokenSearchStruct.s_cContentTokenSearch[
                _hashId
            ] = CContentTokenStorage.CContentToken({
                numToken: _numToken,
                cSupplyVal: _cCTKN.cSupplyVal,
                sPriceUsdVal: _cCTKN.sPriceUsdVal,
                cPriceUsdVal: _cCTKN.cPriceUsdVal,
                sSupplyVal: _cCTKN.sSupplyVal,
                sReserveVal: _cCTKN.sReserveVal,
                cReleaseVal: _cCTKN.cReleaseVal
            });

            LibPublishCreatorToken._publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
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
                    revert PublishCVariantBatch__LengthMismatch();
            }
            // Variant association, parent is index[0] of input array
            AssociatedContentStruct.s_variantMap[_baseHashId][
                _variantIndex
            ] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

            // Emit per-variant event
            emit CVariantPublished(
                _creatorId,
                _baseHashId,
                _hashId,
                _variantIndex
            );
            // unchecked { ++_publishedVariantCount; } **DETERMINE IF WE CAN ENTIRELY REPLACE THIS WITH .LENGTH OR 'i'
            unchecked {
                ++i;
            }
        }
        // possibly emit SVariantPublishCount mapping
        emit CContentTokenBatchPublished(_creatorId, uint16(_hashLength));
    }*/

    ///
    ///
    ///
    ///
    ///
    ///
    ///
    /*function publishCVariantStackTest(
        address _creatorId,
        bytes32[] calldata _baseHashIdBatch,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] calldata _variantIndexBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (
            _hashIdBatch.length < 2 ||
            _cContentToken.length != _hashIdBatch.length ||
            _collaborator.length != _hashIdBatch.length
        ) revert PublishCContentTokenBatch__LengthMismatch();
        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenWavSuppliesTest(
                    _hashIdBatch,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        {
            LibPublishCContentTokenSearchBatch.publishStackTest(
                _creatorId,
                _hashIdBatch,
                _cContentToken,
                _collaborator
                //_royaltyMapBatch
            );
        }

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            uint16 _variantIndex = _variantIndexBatch[i];
            bytes32 _baseHashId = _baseHashIdBatch[i];
            if (_variantIndex == 0) revert PublishSVariantBatch__IndexIssue();
            AssociatedContentStruct.s_variantMap[_baseHashId][
                _variantIndex
            ] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

            emit SVariantPublished(
                _creatorId,
                _hashIdBatch[0],
                _hashId,
                _variantIndex
            );
            unchecked {
                ++i;
            }
        }
    }*/
    ///
    ///
    ///
    ///
    ///
    ///
    ///
    ///

    /*function publishCContentTokenVariantBatchStackTest(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] _variantIndexBatch,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenWavSuppliesTest(
                    _hashIdBatch,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            LibPublishSContentTokenSearch._publishSContentTokenSearchTest(
                _creatorId,
                _hashId,
                _sContentToken,
                _collaborator
            );
            if (i = 0) {
                emit CContentTokenPublished(
                    creatorId,
                    hashIdBatch[0],
                    _cContentToken.numToken[0]
                );
            } else {
                uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0)
                    revert PublishCVariantBatch__IndexIssue();
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][
                    _variantIndex
                ] = _hashId;
                AssociatedContentStruct.s_variantSearch[_hashId] = _hashIdBatch[
                    0
                ];

                emit CVariantPublished(
                    _creatorId,
                    _hashIdBatch[0],
                    _hashIdBatch[i],
                    _variantIndex
                );
            }
        }
    }*/
    //
    //
    //
    //
    //
    //
    //
    //
    //
    //
    //

    /** **** JUST ADDED _priceMapPages into this function we may need to look over other publish functions ****
     * @notice Publishes two or more CContentToken Variants.
     * @dev Writes and stores the data of two or more CContentToken Variants on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        {
            LibPublishCContentTokenSearchBatch
                ._publishCContentTokenVariantSearchBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _collaborator
                );
        }

        for (uint256 i = 0; i < _cContentToken.length; ) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            LibPublishVariantHelper._publishVariantHelper(_cTV);
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Publishes a single CContentToken alongside two or more CContentToken Variants.
     * @dev Writes and stores the data of multiple CContentTokens, including one or more CContentToken Variants, on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     * @param _priceMapPages 2-bit state map representing the price states of numToken index positions.
     */
    function publishCContentTokenVariantBatch(
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _tierMapPages,
        uint256[] calldata _priceMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        {
            LibPublishCContentTokenWavSuppliesBatch
                ._publishCContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _cContentToken,
                    _tierMapPages,
                    _priceMapPages
                );
        }

        for (uint256 i = 0; i < _cContentToken.length; i++) {
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken[
                i
            ];
            CollaboratorStructStorage.Collaborator
                calldata _collab = _collaborator[i];

            {
                // must be singular version
                LibPublishCContentTokenSearch
                    ._publishCContentTokenVariantSearch(_cTV, _cCTKN, _collab);
            }

            if (i > 0) {
                LibPublishVariantHelper._publishVariantHelper(_cTV);
            }
        }
    }
}
