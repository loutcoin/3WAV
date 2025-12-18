// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
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
    LibPublishSContentTokenWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSuppliesBatch.sol";
/*import {
    LibPublishSContentTokenWavSupplies
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibPublishSContentTokenWavSupplies.sol";*/
/*import {
    AssociatedContentMap
} from "../../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";*/

import {
    LibPublishSContentTokenSearchBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearchBatch.sol";

import {
    LibPublishVariantHelper
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishVariantHelper.sol";

import {
    LibPublishSContentTokenSearch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibPublishSContentTokenSearch.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

contract PublishSVariantBatch {
    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken,
        uint32 priceUsdVal,
        uint112 supplyVal,
        uint96 releaseVal
    );

    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    event SContentTokenBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event SVariantBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    error PublishSVariantBatch__LengthMismatch();
    error PublishSVariantBatch__NumInputInvalid();
    error PublishSVariantBatch__IndexIssue();

    /**
     *  Publishes a single SContentToken alongside two or more SContentToken Variants.
     *  Writes and stores the data of multiple SContentTokens, including one or more SContentToken Variants, on the blockchain.
     *  _creatorId The address of the creator.
     *  _hashIdBatch Batch of Content Token identifier values being queried.
     *  _sContentToken Batch of user-defined SContentToken structs.
     *  _collaborator Batch of user-defined Collaborator structs.
     *  _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * _variantIndexBatch Batch of numerical indexes correlating to the total Variants of a base Content Token.
     */
    /*function publishSContentTokenVariantBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _royaltyMapBatch,
        uint16[] calldata _variantIndexBatch
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _sContentToken.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength
        ) revert PublishSVariantBatch__LengthMismatch();

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

        uint112[] memory _supplyValBatch = new uint112[](_hashLength);

        LibPublishSContentTokenWavSuppliesBatch
            ._publishSContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _supplyValBatch
            );

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            if (_numToken == 0 || _sCTKN.supplyVal == 0)
                revert PublishSVariantBatch__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
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
                    revert PublishSVariantBatch__LengthMismatch();
            }

            if (i == 0) {
                emit SContentTokenPublished(
                    _creatorId,
                    _hashId,
                    _numToken,
                    _sCTKN.priceUsdVal,
                    _sCTKN.supplyVal,
                    _sCTKN.releaseVal
                );
            } else {
                uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0)
                    revert PublishSVariantBatch__IndexIssue();
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][
                    _variantIndex
                ] = _hashId;
                AssociatedContentStruct.s_variantSearch[_hashId] = _hashIdBatch[
                    0
                ];

                emit SVariantPublished(
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

        emit SContentTokenBatchPublishedCount(_creatorId, uint16(_hashLength));
    }*/

    /*function publishSVariantBatch(
        address _creatorId,
        bytes32[] calldata _baseHashIdBatch,
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _royaltyMapBatch,
        uint16[] calldata _variantIndexBatch
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _sContentToken.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength
        ) revert PublishSVariantBatch__LengthMismatch();

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

        uint112[] memory _supplyValBatch = new uint112[](_hashLength);

        LibPublishSContentTokenWavSuppliesBatch
            ._publishSContentTokenWavSuppliesBatch(
                _hashIdBatch,
                _supplyValBatch
            );

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            bytes32 _baseHashId = _baseHashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            if (_numToken == 0 || _sCTKN.supplyVal == 0)
                revert PublishSVariantBatch__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
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
            }

            uint16 _variantIndex = _variantIndexBatch[i];
            if (_variantIndex == 0) revert PublishSVariantBatch__IndexIssue();
            AssociatedContentStruct.s_variantMap[_baseHashId][
                _variantIndex
            ] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

            emit SVariantPublished(
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
        emit SVariantBatchPublishedCount(_creatorId, uint16(_hashLength));
    }*/

    /**
     * @notice Publishes two or more SContentToken Variants.
     * @dev Writes and stores the data of two or more SContentToken Variants on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined CreatorTokenVariant structs.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     */
    function publishSVariantBatch(
        //address _creatorId,
        //bytes32[] calldata _baseHashIdBatch,
        //bytes32[] calldata _hashIdBatch,
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
        //uint16[] calldata _variantIndexBatch
    ) external {
        ReturnValidation.returnIsAuthorized();
        {
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _sContentToken
                );
        }
        {
            /*LibPublishSContentTokenSearchBatch._publishSContentTokenVariantBatchStackTest(
                _creatorId,
                _hashIdBatch,
                _sContentToken,
                _collaborator
            );*/
            LibPublishSContentTokenSearchBatch
                ._publishSContentTokenVariantSearchBatch(
                    _creatorTokenVariant,
                    _sContentToken,
                    _collaborator
                );
        }
        /*AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();*/

        for (uint256 i = 0; i < _sContentToken.length; i++) {
            /*uint16 _variantIndex = _variantIndexBatch[i];
            bytes32 _baseHashId = _baseHashIdBatch[i];
            if (_variantIndex == 0) revert PublishSVariantBatch__IndexIssue();
            AssociatedContentStruct.s_variantMap[_baseHashId][
                _variantIndex
            ] = _hashIdBatch[i];
            AssociatedContentStruct.s_variantSearch[
                _hashIdBatch[i]
            ] = _baseHashId[i];

            emit SVariantPublished(
                _creatorId,
                _hashIdBatch[0],
                _hashIdBatch[i],
                _variantIndex
            );
            unchecked {
                ++i;
            }*/
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];
            LibPublishVariantHelper._publishVariantHelper(_cTV);
        }
    }

    /**
     * @notice Publishes a single SContentToken alongside two or more SContentToken Variants.
     * @dev Writes and stores the data of multiple SContentTokens, including one or more SContentToken Variants, on the blockchain.
     * @param _creatorTokenVariant Batch of user-defined _creatorTokenVariants
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     */
    function publishSContentTokenVariantBatch(
        //address _creatorId,
        //bytes32[] calldata _hashIdBatch,
        CreatorTokenVariantStorage.CreatorTokenVariant[] calldata _creatorTokenVariant,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator
        //uint16[] calldata _variantIndexBatch
    ) external {
        ReturnValidation.returnIsAuthorized();
        {
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenVariantWavSuppliesBatch(
                    _creatorTokenVariant,
                    _sContentToken
                );
        }

        /*AssociatedContentMap.AssociatedContent
            storage AssociatedContentStruct = AssociatedContentMap
                .associatedContentMap();*/

        for (uint256 i = 0; i < _sContentToken.length; i++) {
            /*LibPublishSContentTokenSearch._publishSContentTokenSearchTest(
                _creatorId,
                _hashIdBatch[i],
                _sContentToken[i],
                _collaborator[i]
            );*/
            CreatorTokenVariantStorage.CreatorTokenVariant
                calldata _cTV = _creatorTokenVariant[i];

            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            CollaboratorStructStorage.Collaborator
                calldata _collab = _collaborator[i];

            LibPublishSContentTokenSearch._publishSContentTokenVariantSearch(
                _cTV,
                _sCTKN,
                _collab
            );
            if (i > 0) {
                /*uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0)
                    revert PublishSVariantBatch__IndexIssue();
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][
                    _variantIndex
                ] = _hashIdBatch[i];
                AssociatedContentStruct.s_variantSearch[
                    _hashIdBatch[i]
                ] = _hashIdBatch[0];

                emit SVariantPublished(
                    _creatorId,
                    _hashIdBatch[0],
                    _hashIdBatch[i],
                    _variantIndex
                );*/
                LibPublishVariantHelper._publishVariantHelper(_cTV);
            }
        }
    }

    /*
    {
            LibPublishSContentTokenWavSuppliesBatch
                ._publishSContentTokenWavSuppliesTest(
                    _hashIdBatch,
                    _sContentToken
                );
        }
        {   // This ACTUALLY needs to be made differently for this type of function,
            // ****OR we can just use the SINGLE version of this function, as we know i[0] 
            // Is going to be the only non-variant
            LibPublishSContentTokenSearchBatch._publishSContentStackTest(
                _creatorId,
                _hashIdBatch,
                _sContentToken,
                _collaborator
            );
        }

    */
}
