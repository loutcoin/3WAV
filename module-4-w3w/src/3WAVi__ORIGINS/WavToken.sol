// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavDBC} from "../3WAVi__ORIGINS/WavDBC.sol";
// import {WavRoot} from "../src/WavRoot.sol";
import {SContentTokenStorage} from "../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
import {CContentTokenStorage} from "../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
import {ContentTokenSupplyMapStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
// import {ContentTokenPriceMapStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenPriceMapStorage.sol";
import {ContentTokenSearchStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
import {ContentTokenFlagStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenFlagStorage.sol";
// Optionals:
import {CollaboratorStructStorage} from "../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";
import {CollaboratorMapStorage} from "../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorMapStorage.sol";
import {AssociatedContentMap} from "../../src/Diamond__Storage/ContentToken/Optionals/AssociatedContentMap.sol";
import {VariantMapStorage} from "../../src/Diamond__Storage/ContentToken/Optionals/VariantMapStorage.sol";
import {VariantStructStorage} from "../../src/Diamond__Storage/ContentToken/Optionals/VariantStructStorage.sol";
import {VersionStemStorage} from "../../src/Diamond__Storage/ContentToken/Optionals/VersionStemStorage.sol";
// CreatorToken:
import {CreatorTokenStorage} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {CreatorTokenMapStorage} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
// AuthorizedAddr:
import {AuthorizedAddrStorage} from "../../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrStorage.sol";
// 3WAVi__Helpers
import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";

//Struct, Event and Error Definitions
//If struct or error is used across many files, define in own file. Multiple structs and errors defined together single file.

contract WavToken {
    error WavToken__IsNotLout();
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();
    error WavToken__BitmapOverflow();
    error WavToken__RSaleMismatch();
    error WavToken__RSaleOverflow();

    error WavToken__NumInputInvalid();
    error WavToken__LengthMismatch();
    error WavToken__IndexIssue();

    // We got to figure out how to handle storage and deduction of supply #1 priority
    // We have 'TokenBalanceStorage' but that's for users we need something for supply allocation deductions, etc;
    // We could maybe even store an 'Encoded' remaning balance that encodes and decodes containing:
    // WavStore balance, WavReserve balance, preReserve balance
    // 'TokenBalanceStorage' will still handle user and creatorId balances

    event SContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken,
        uint32 priceUsdVal,
        uint112 supplyVal,
        uint96 releaseVal,
        uint8 numCollaborator
    );

    event SContentTokenBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event SContentTokenVariantBatchPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        uint16 indexed variantCount
    );

    event SVariantPublished(
        address indexed creatorId,
        bytes32 indexed parentHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    event SVariantBatchPublishedCount(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event CContentTokenPublished(
        address indexed creatorId,
        bytes32 indexed hashId,
        uint16 indexed numToken
    );

    event CContentTokenBatchPublished(
        address indexed creatorId,
        uint16 indexed publicationCount
    );

    event CVariantPublished(
        address indexed creatorId,
        bytes32 indexed baseHashId,
        bytes32 indexed variantHashId,
        uint16 variantIndex
    );

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _priceUsdVal Unsigned interger containing Content Token price definition.
     * @param _supplyVal Unsigned interger containing Content Token supply data
     * @param _releaseVal Unsigned interger containing timestamp publication data.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     */
    function publishSContentToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint32 _priceUsdVal,
        uint112 _supplyVal,
        uint96 _releaseVal,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) external {
        ReturnValidation.returnIsAuthorized();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        if (_numToken == 0 || _supplyVal == 0) {
            revert WavToken__NumInputInvalid();
        }

        ContentTokenSearchStruct.s_sContentTokenSearch[
            _hashId
        ] = SContentTokenStorage.SContentToken({
            numToken: _numToken,
            priceUsdVal: _priceUsdVal,
            supplyVal: _supplyVal,
            releaseVal: _releaseVal
        });

        /*uint256 _contentId = ++ContentTokenMap.s_ownershipIndex[_creatorId];
        CreatorTokenStorage.CreatorToken storage CreatorTokenStruct = CreatorTokenMapStruct.s_publishedTokenData[_hashId][_numToken];
        CreatorTokenStruct.creatorId = _creatorId;
        CreatorTokenStruct.contentId = _contentId;
        CreatorTokenStruct.hashId = _hashId;
        CreatorTokenMap.s_ownershipMap[_creatorId][_contentId][_hashId] = _numToken;
        
        CreatorTokenMapStruct.s_publishedTokenData[_hashId][_numToken] = CreatorTokenStruct;
        CreatorTokenMapStruct.s_ownershipMap[_creatorId][_contentId][_hashId] = _numToken;*/
        _publishCreatorToken(_creatorId, _hashId, _numToken);

        _publishSContentTokenWavSupplies(_hashId, _supplyVal);

        if (_numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[_hashId]({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;

            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        }

        // Emit Event
        emit SContentTokenPublished(
            _creatorId,
            _hashId,
            _numToken,
            _priceUsdVal,
            _supplyVal,
            _releaseVal,
            _numCollaborator
        );
    }

    // If For CContentToken publication implementation the Stack limit becomes too problematic,
    // I think we could make the wavReserve stuff occur in the function body through external function calls
    // That at most would only include 1 (possibly 0) local variable definitions instead of 3
    /* function publishSContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint32[] calldata _priceUsdValBatch,
        uint112[] calldata _supplyValBatch,
        uint96[] calldata _releaseValBatch,
        uint8[] calldata _numCollaboratorBatch,
        uint128[] calldata _royaltyValBatch,
        uint256[] calldata _royaltyMapBatch
    ) external {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength == 0) revert WavToken__LengthMismatch();
        if(
            _numTokenBatch.length != _hashLength ||
            _priceUsdValBatch.length != _hashLength ||
            _supplyValBatch.length != _hashLength ||
            _releaseValBatch.length != _hashLength ||
            _numCollaborator.length != _hashLength ||
            _royaltyValBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CreatorTokenMapStorage.CreatorTokenMap storage CreatorTokenMapStruct =
        CreatorTokenMapStorage.creatorTokenMapStructStorage();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
        ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        // Reusable temporaries 
        bytes32 _hashId;
        uint16 _numToken;
        uint32 _priceUsd;
        uint112 _supplyVal;
        uint96 _releaseVal;
        uint8 _numCollaborators;
        uint128 _royaltyVal;
        uint256 _royaltyMap;

        for(uint256 i = 0; i < _hashLength;) {
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _priceUsd = _priceUsdValBatch[i];
            _supplyVal = _supplyUsdValBatch[i];
            _releaseVal = _releaseValBatch[i];
            _numCollaborators = _numCollaboratorBatch[i];
            _royaltyVal = _royaltyValBatch[i];
            _royaltyMap = _royaltyMapBatch[i];

            // Shared validation
            if(
                _numToken == 0 ||
                _supplyVal == 0
            ) revert WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId] = SContentToken({
                numToken: _numToken,
                priceUsdVal: _priceUsdVal,
                supplyVal: _supplyVal,
                releaseVal: _releaseVal
            });

            uint256 _contentId = ++ContentTokenMap.s_ownershipIndex[_creatorId];
            CreatorTokenStorage.CreatorToken storage CreatorTokenStruct = CreatorTokenMapStruct.s_publishedTokenData[_hashId][_numToken];
            CreatorTokenStruct.creatorId = _creatorId;
            CreatorTokenStruct.contentId = _contentId;
            CreatorTokenStruct.hashId = _hashId;
            ContentTokenMap.s_ownershipMap[_creatorId][_contentId][_hashId] = _numToken;

            (, uint112 _initialSupply, uint112 _wavReserve, uint112 _preRelease) = cSupplyValDecoder(_supplyVal);
                ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = remainingSupplyEncoder(_initialSupply, _wavReserve, _preRelease);

            if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }

          emit SContentTokenPublished(_creatorId, _hashId, _numToken, _priceUsd, _supplyVal, _releaseVal, _numCollaborators);

            unchecked { ++i; }
        }
        emit SContentTokenBatchPublishedCount(_creatorId, uint16(_hashLength));

    } */

    /*function publishSContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint32[] calldata _priceUsdValBatch,
        uint112[] calldata _supplyValBatch,
        uint96[] calldata _releaseValBatch,
        uint8[] calldata _numCollaboratorBatch,
        uint128[] calldata _royaltyValBatch,
        uint256[] calldata _royaltyMapBatch
    ) external {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength == 0) revert WavToken__LengthMismatch();
        if(
            _numTokenBatch.length != _hashLength ||
            _priceUsdValBatch.length != _hashLength ||
            _supplyValBatch.length != _hashLength ||
            _releaseValBatch.length != _hashLength ||
            _numCollaborator.length != _hashLength ||
            _royaltyValBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        // Reusable temporaries 
        bytes32 _hashId;
        uint16 _numToken;
        uint32 _priceUsd;
        uint112 _supplyVal;
        uint96 _releaseVal;
        uint8 _numCollaborators;
        uint128 _royaltyVal;
        uint256 _royaltyMap;

        _publishSContentTokenWavSuppliesBatch(
            _hashIdBatch,
            _supplyValBatch
        );

        for(uint256 i = 0; i < _hashLength;) {
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _priceUsd = _priceUsdValBatch[i];
            _supplyVal = _supplyUsdValBatch[i];
            _releaseVal = _releaseValBatch[i];
            _numCollaborators = _numCollaboratorBatch[i];
            _royaltyVal = _royaltyValBatch[i];
            _royaltyMap = _royaltyMapBatch[i];

            // Shared validation
            if(
                _numToken == 0 ||
                _supplyVal == 0
            ) revert WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId] = SContentToken({
                numToken: _numToken,
                priceUsdVal: _priceUsdVal,
                supplyVal: _supplyVal,
                releaseVal: _releaseVal
            });

            _publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }

          emit SContentTokenPublished(_creatorId, _hashId, _numToken, _priceUsd, _supplyVal, _releaseVal, _numCollaborators);

            unchecked { ++i; }
        }
        emit SContentTokenBatchPublishedCount(_creatorId, uint16(_hashLength));
    }*/

    /* SContentTokenStruct.numToken = _numToken;
        SContentTokenStruct.priceUsdVal = _priceUsdVal;
        SContentTokenStruct.supplyVal = _supplyVal;
        SContentTokenStruct.

    */

    /**
     * @notice Publishes a batch of two or more user-defined SContentTokens.
     * @dev Writes and stores the data of multiple SContentTokens on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     */
    function publishSContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        SContentTokenStorage.SContentToken[] calldata _sContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _royaltyMapBatch
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;

        if (
            _hashLength < 2 ||
            _sContentToken.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint112[] memory _supplyValBatch = new uint112[](_hashLength);

        _publishSContentTokenWavSuppliesBatch(_hashIdBatch, _supplyValBatch);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            // Shared validation ****_supplyVal should not be less than min Encoded****
            if (_numToken == 0 || _sCTKN.supplyVal == 0)
                revert WavToken__NumInputInvalid();

            SContentTokenStorage.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
            });

            _publishCreatorToken(_creatorId, _hashId, _numToken);

            /*if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }*/

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    _collab.s_collaborators[_hashId] = CollaboratorStructStorage
                        .Collaborator({
                            numCollaborator: _collab.numCollaborator,
                            royaltyVal: _collab.royaltyVal
                        });
                    _collab.s_royalties[_hashId] = _royaltyMapBatch[i];
                    _collab.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0) revert WavToken__LengthMismatch();
            }

            emit SContentTokenPublished(
                _creatorId,
                _hashId,
                _numToken,
                _sCTKN.priceUsd,
                _sCTKN.supplyVal,
                _sCTKN.releaseVal,
                _sCTKN.numCollaborators
            );

            unchecked {
                ++i;
            }
        }

        emit SContentTokenBatchPublishedCount(_creatorId, uint16(_hashLength));
    }

    // Complete function:
    // See, the thing is I genuinely think all distinctions between locally defined variables
    // between Variants and the SContentToken can be ENTIRELY removed with sole exception,
    // being to the additional mapping writes, that's what I need to focus on doing
    // If I cannot do this I will fully disable this function for time-sake

    // INCORPORATE BASEHASHID
    /*function publishSContentTokenVariantBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch
        uint32[] calldata _priceUsdValBatch,
        uint112[] calldata _supplyValBatch,
        uint96[] calldata _releaseValBatch,
        uint16[] calldata _variantIndexBatch
        uint8[] calldata _numCollaboratorBatch,
        uint128[] calldata _royaltyValBatch,
        uint256[] calldata _royaltyMapBatch
    ) external {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength == 0) revert WavToken__LengthMismatch();
        if(
            _numTokenBatch.length != _hashLength ||
            _priceUsdValBatch.length != _hashLength ||
            _supplyValBatch.length != _hashLength ||
            _releaseValBatch.length != _hashLength ||
            _numCollaborator.length != _hashLength ||
            _royaltyValBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength
        ) revert WavToken__LengthMismatch();
        
        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent storage AssociatedContentStruct =
        AssociatedContentMap.associatedContentMap();

        // Reusable temporaries 
        bytes32 _hashId;
        uint16 _numToken;
        uint32 _priceUsd;
        uint112 _supplyVal;
        uint96 _releaseVal;
        uint16 _variantIndex;
        uint8 _numCollaborators;
        uint128 _royaltyVal;
        uint256 _royaltyMap;

        // Small counter for emitted Variant events
        //uint16 _publishedVariantCount = 0;

        _publishSContentTokenWavSuppliesBatch(
            _hashIdBatch,
            _supplyValBatch
        );

        for(uint256 i = 0; i < _hashLength;) {
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _priceUsd = _priceUsdValBatch[i];
            _supplyVal = _supplyUsdValBatch[i];
            _releaseVal = _releaseValBatch[i];
            _variantIndex = _variantIndexBatch[i];
            _numCollaborators = _numCollaboratorBatch[i];
            _royaltyVal = _royaltyValBatch[i];
            _royaltyMap = _royaltyMapBatch[i];

            // Shared validation
            if(
                _numToken == 0 ||
                _supplyVal == 0
            ) revert WavToken__NumInputInvalid();

            
            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId] = SContentToken({
                numToken: _numToken,
                priceUsdVal: _priceUsdVal,
                supplyVal: _supplyVal,
                releaseVal: _releaseVal
            });
                // Need to see if this memory operation increments stack if so...
                // This function MAY be possible but I'd also consider deprecating it from MVP build for time
                // Don't spend more than a single full work day trying to make this work comment it out return to it post v0.01.0
                
               
            _publishCreatorToken(
            _creatorId,
            _hashId,
            _numToken
            );

            if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
                }

            if(i == 0) {
                    // "Parent" handled above. Everything below only relevant for Variant
            } else {
                // Variant association, parent is index[0] of input array
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][_variantIndex] = _hashId;
                AssociatedContentStruct.s_variantSearch[_hashId] = _hashIdBatch[0];
                // Emit per-variant event
                emit SVariantPublished(_creatorId, _hashIdBatch[0], _hashId, _variantIndex);
                //unchecked { ++_publishedVariantCount; }
            }

            unchecked { ++i; }
        }

        emit SContentTokenVariantBatch(_creatorId, _hashIdBatch[0], uint16(_hashLength));
    }*/

    /**
     * @notice Publishes a single SContentToken alongside two or more SContentToken Variants.
     * @dev Writes and stores the data of multiple SContentTokens, including one or more SContentToken Variants, on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _variantIndexBatch Batch of numerical indexes correlating to the total Variants of a base Content Token.
     */
    function publishSContentTokenVariantBatch(
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
        ) revert WavToken__LengthMismatch();

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

        _publishSContentTokenWavSuppliesBatch(_hashIdBatch, _supplyValBatch);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            if (_numToken == 0 || _sCTKN.cSupplyVal == 0)
                revert WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
            });

            _publishCreatorToken(_creatorId, _hashId, _numToken);
            /*if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
                }

            if(i == 0) {
                    // "Parent" handled above. Everything below only relevant for Variant
            } else {
                // Variant association, parent is index[0] of input array
                AssociatedContentStruct.s_variantMap[_hashIdBatch[0]][_variantIndex] = _hashId;
                AssociatedContentStruct.s_variantSearch[_hashId] = _hashIdBatch[0];
                // Emit per-variant event
                emit SVariantPublished(_creatorId, _hashIdBatch[0], _hashId, _variantIndex);
                //unchecked { ++_publishedVariantCount; }
            }*/
            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    _collab.s_collaborators[_hashId] = CollaboratorStructStorage
                        .Collaborator({
                            numCollaborator: _collab.numCollaborator,
                            royaltyVal: _collab.royaltyVal
                        });
                    _collab.s_royalties[_hashId] = _royaltyMapBatch[i];
                    _collab.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0) revert WavToken__LengthMismatch();
            }

            if (i == 0) {
                emit SContentTokenPublished(_creatorId, _hashId, _numToken);
            } else {
                uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0) revert WavToken__IndexIssue();
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

        emit SContentTokenBatchPublishedCount(
            _creatorId,
            _hashIdBatch[0],
            uint16(_hashLength)
        );
    }

    /**
     * @notice Publishes a single user-defined SContentToken.
     * @dev Writes and stores the data of a SContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _priceUsdVal Unsigned interger containing Content Token price definition.
     * @param _supplyVal Unsigned interger containing Content Token supply data
     * @param _releaseVal Unsigned interger containing timestamp publication data.
     * @param _variantIndex Numerical index correlating to the total Variant count of a Content Token.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     */
    function publishSVariant(
        address _creatorId,
        bytes32 _baseHashId,
        bytes32 _hashId,
        uint16 _numToken,
        uint32 _priceUsdVal,
        uint112 _supplyVal,
        uint96 _releaseVal,
        uint16 _variantIndex,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_numToken == 0 || _supplyVal == 0 || _variantIndex == 0) {
            revert WavToken__NumInputInvalid();
        }
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

        ContentTokenSearchStruct.s_sContentTokenSearch[
            _hashId
        ] = SContentTokenStorage.SContentToken({
            numToken: _numToken,
            priceUsdVal: _priceUsdVal,
            supplyVal: _supplyVal,
            releaseVal: _releaseVal
        });

        _publishCreatorToken(_creatorId, _hashId, _numToken);

        _publishSContentTokenWavSupplies(_hashId, _supplyVal);

        /*(, uint112 _initialSupply, uint112 _wavReserve, uint112 _preRelease) = cSupplyValDecoder(_supplyVal);
        ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = remainingSupplyEncoder(_initialSupply, _wavReserve, _preRelease);*/

        if (_numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        }
        // Variant association, parent is index[0] of input array
        AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

        emit SVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
    }

    // We either have to rely on the front-end to validate current variantIndex before calling,
    // Or determine it in this function, however considering how large these functions are,
    // Also considering how close to Stack Too Deep each function is to the point of requiring
    // Revisions and refinement to avoid the error, this might be a task entrusted to the front-end for now
    // --
    // With a 'bytes32 _baseHashId => uint16 variantIndex' mapping, we COULD remove the '_variantIndexBatch' input
    // It'd likely increase gas costs overall, but similarly to _wavSupplies, could be determined in the function,
    // this would only be feasible if we could do this with only creating a single local ('_variantIndex')
    // Or else Stack Too Deep would become problematic

    /*function publishSVariantBatch(
        address _creatorId,
        bytes32[] calldata _baseHashIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch
        uint32[] calldata _priceUsdValBatch,
        uint112[] calldata _supplyValBatch,
        uint96[] calldata _releaseValBatch,
        uint16[] calldata _variantIndexBatch
        uint8[] calldata _numCollaboratorBatch,
        uint128[] calldata _royaltyValBatch,
        uint256[] calldata _royaltyMapBatch
    ) external {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength < 2) revert WavToken__LengthMismatch();
        if(
            _baseHashIdBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength ||
            _priceUsdValBatch.length != _hashLength ||
            _supplyValBatch.length != _hashLength ||
            _releaseValBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength ||
            _numCollaboratorBatch.length != _hashLength ||
            _royaltyValBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent storage AssociatedContentStruct =
        AssociatedContentMap.associatedContentMap();

        // Reusable temporaries 
        bytes32 _baseHashId;
        bytes32 _hashId;
        uint16 _numToken;
        uint32 _priceUsd;
        uint112 _supplyVal;
        uint96 _releaseVal;
        uint16 _variantIndex;
        uint8 _numCollaborator;
        uint128 _royaltyVal;
        uint256 _royaltyMap;

        _publishSContentTokenWavSuppliesBatch(
            _hashIdBatch,
            _supplyValBatch
        );

        for(uint256 i = 0; i < _hashLength;) {
            _baseHashId = _baseHashIdBatch[i];
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _priceUsd = _priceUsdBatch[i];
            _supplyVal = _supplyValBatch[i];
            _releaseVal = _releaseValBatch[i];
            _variantIndex = _variantIndexBatch[i];
            _numCollaborator = _numCollboratorBatch[i];
            _royaltyVal = _royaltyValBatch[i];
            _royaltyMap = _royaltyMapBatch[i];

            // Shared validation
            if(
                _numToken == 0 ||
                _supplyVal == 0 ||
                _variantIndex == 0
            ) {
                WavToken__NumInputInvalid();
            }

            ContentTokenSearchStruct.s_sContentTokenSearch[_hashId] = SContentToken({
                numToken: _numToken,
                priceUsdVal: _priceUsdVal,
                supplyVal: _supplyVal,
                releaseVal: _releaseVal
            });

            _publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            )

            if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }
            // Variant association, parent is index[0] of input array
            AssociatedContentStruct.s_variantMap[_baseHashId][_variantIndex] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _parentId;

            // Emit per-variant event
            emit SVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
            // unchecked { ++_publishedVariantCount; } **DETERMINE IF WE CAN ENTIRELY REPLACE THIS WITH .LENGTH OR 'i'
            unchecked { ++i; }
        }
        // possibly emit SVariantPublishCount mapping
        emit SVariantBatchPublishedCount(_creatorId, uint16(_hashLength));
    } */

    /* bytes32[] memory _variantIds;
        uint256 _variantCount = 0;
        if(_hashLength > 1) _variantIds = new bytes32[](_hashLength - 1); */

    // ContentTokenMap.s_publishedTokenData[_hashId][_numToken] = CreatorTokenStruct;

    /* ContentTokenSearchStruct.s_sContentTokenSearch[_hashId] = SContentToken({
            numToken: _numToken,
            priceUsdVal: _priceUsd,
            supplyVal: _supplyVal,
            releaseVal: _releaseVal,
        }); */

    /**
     * @notice Publishes two or more SContentToken Variants.
     * @dev Writes and stores the data of two or more SContentToken Variants on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _baseHashIdBatch The Content Token associated to a derivative Variant.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _sContentToken Batch of user-defined SContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _variantIndexBatch Batch of numerical indexes correlating to the total Variants of a base Content Token.
     */
    function publishSVariantBatch(
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
        ) revert WavToken__LengthMismatch();

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

        _publishSContentTokenWavSuppliesBatch(_hashIdBatch, _supplyValBatch);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken[
                i
            ];
            uint16 _numToken = _sCTKN.numToken;

            if (_numToken == 0 || _sCTKN.cSupplyVal == 0)
                revert WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_sContentTokenSearch[
                _hashId
            ] = SContentTokenStorage.SContentToken({
                numToken: _numToken,
                priceUsdVal: _sCTKN.priceUsdVal,
                supplyVal: _sCTKN.supplyVal,
                releaseVal: _sCTKN.releaseVal
            });

            _publishCreatorToken(_creatorId, _hashId, _numToken);

            if (CollaboratorStructStorage.numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[
                    _hashId
                ] = CollaboratorStructStorage.Collaborator({
                    numCollaborator: CollaboratorStructStorage.numCollaborators,
                    royaltyVal: CollaboratorStructStorage.royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMapBatch;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }
            // Variant association, parent is index[0] of input array
            AssociatedContentStruct.s_variantMap[_baseHashIdBatch][
                _variantIndexBatch
            ] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashIdBatch;

            // Emit per-variant event
            emit SVariantPublished(
                _creatorId,
                _baseHashIdBatch,
                _hashId,
                _variantIndexBatch
            );
            // unchecked { ++_publishedVariantCount; } **DETERMINE IF WE CAN ENTIRELY REPLACE THIS WITH .LENGTH OR 'i'
            unchecked {
                ++i;
            }
        }
        // possibly emit SVariantPublishCount mapping
        emit SVariantBatchPublishedCount(_creatorId, uint16(_hashLength));
    }

    /*function publishCContentToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint32 _cPriceUsdVal,
        uint112 _sTotalSupplyVal,
        uint112 _sInitialSupplyVal,
        uint80 _sWavR,
        uint80 _sPreSaleR,
        uint96 _cReleaseVal,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap
    ) external {
        onlyAuthorized();

        if(
            _numToken == 0 ||
            _cSupplyVal == 0
        ) revert WavToken__NumInputInvalid();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CreatorTokenMapStorage.CreatorTokenMap storage CreatorTokenMapStruct =
        CreatorTokenMapStorage.creatorTokenMapStructStorage();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
        ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        ContentTokenSearchStruct.s_cContentTokenSearch[_hashId] = CContentToken({
            numToken: _numToken,
            cSupplyVal: _cSupplyVal,
            sPriceUsdVal: _sPriceUsdVal,
            cPriceUsdVal: _cPriceUsdVal,
            sTotalSupply: _sTotalSupply,
            sInitialSupply: _sInitialSupply,
            sWavR: _sWavR,
            sPreSaleR: _sPreSaleR,
            cReleaseVal: _cReleaseVal
        });

        // This could possibly be off-loaded as well
        uint256 _contentId = ++ContentTokenMap.s_ownershipIndex[_creatorId];
        CreatorTokenStorage.CreatorToken storage CreatorTokenStruct = CreatorTokenMapStruct.s_publishedTokenData[_hashId][_numToken];
        CreatorTokenStruct.creatorId = _creatorId;
        CreatorTokenStruct.contentId = _contentId;
        CreatorTokenStruct.hashId = _hashId;
        ContentTokenMap.s_ownershipMap[_creatorId][_contentId][_hashId] = _numToken;

        // Has to be optimized to ONLY store result and define *NO* locals in this execution context
        // THE ONLY WAY IS TO OFF-LOAD THIS 
        /* (, uint112 _initialSupply, uint112 _wavReserve, uint112 _preRelease) = cSupplyValDecoder(_supplyVal);
        ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = remainingSupplyEncoder(_initialSupply, _wavReserve, _preRelease);
        uint112 _wavStoreSupply = remainingSupplyEncoder(_initialSupply, _wavReserve, _preRelease);

        ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _wavStoreSupply 
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][0] = _wavStoreSupply*/

    /* publishCContentTokenWavSupplies(
            _hashId
            _cSupplyVal,
            _sInitialSupplyVal,
            _sWavR,
            _sPreSaleR
        );

        // enable bitmap and stuff glossed over should be incorporated
        if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }

            emit CContentTokenPublished(_creatorId, _hashId, _numToken);
    } */

    // uint32 cPriceUsdVal could be deprecated for CContentTokens and (perfectly) replaced with 'uint128 priceUsdVal',
    // but the wide-reaching effects of such a decision could likley take over a full week of work to correct

    /**
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _cSupplyVal Unsigned interger containing the collection supply data.
     * @param _sPriceUsdVal Unsigned interger containing seperate sale price properties.
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
     * @param _sSupplyVal Unsigned interger containing Content Token supply data.
     * @param _sReserveVal Unsigned interger containing seperate sale reserve values.
     * @param _cReleaseVal Unsigned interger containing timestamp publication data.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    function publishCContentToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint32 _cPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint96 _cReleaseVal,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap,
        uint256[] calldata _tierMapPages //uint256[] calldata _stateMapPages **Deprecated Currently*
    ) external {
        ReturnValidation.returnIsAuthorized();

        if (_numToken == 0 || _cSupplyVal == 0)
            revert WavToken__NumInputInvalid();
        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

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

        _publishCreatorToken(_creatorId, _hashId, _numToken);

        // Needs update
        _publishCContentTokenWavSupplies(
            _hashId,
            _cSupplyVal,
            _sSupplyVal,
            _sReserveVal,
            _tierMapPages
            //_stateMapPages
        );

        // enable bitmap and stuff glossed over should be incorporated
        if (_numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        }

        emit CContentTokenPublished(_creatorId, _hashId, _numToken);
    }

    /**
     * @notice Publishes a batch of two or more user-defined CContentTokens.
     * @dev Writes and stores the data of multiple CContentTokens on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _cContentToken Batch of user-defined CContentToken structs.
     * @param _collaborator Batch of user-defined Collaborator structs.
     * @param _royaltyMapBatch Royalty state map batch of Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    function publishCContentTokenBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _cContentToken.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        _prepareWavSuppliesBatch(_hashIdBatch, _cContentToken, _tierMapPages);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCKTN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCKTN.numToken;

            if (_numToken == 0 || _cCKTN.cSupplyVal == 0)
                WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_cContentTokenSearch[
                _hashId
            ] = CContentTokenStorage.CContentToken({
                numToken: _numToken,
                cSupplyVal: _cCKTN.cSupplyVal,
                sPriceUsdVal: _cCKTN.sPriceUsdVal,
                cPriceUsdVal: _cCKTN.cPriceUsdVal,
                sSupplyVal: _cCKTN.sSupplyVal,
                sReserveVal: _cCKTN.sReserveVal,
                cReleaseVal: _cCKTN.cReleaseVal
            });

            _publishCreatorToken(_creatorId, _hashId, _numToken);

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    _collab.s_collaborators[_hashId] = CollaboratorStructStorage
                        .Collaborator({
                            numCollaborator: _collab.numCollaborator,
                            royaltyVal: _collab.royaltyVal
                        });
                    _collab.s_royalties[_hashId] = _royaltyMapBatch[i];
                    _collab.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0) revert WavToken__LengthMismatch();
            }

            CContentTokenPublished(_creatorId, _hashId, _numToken);

            unchecked {
                ++i;
            }
        }

        emit CContentTokenBatchPublished(_creatorId, uint16(_hashLength));
    }

    /**
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
    function publishCContentTokenVariantBatch(
        address _creatorId,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] calldata _variantIndexBatch,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();
        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength < 2 ||
            _cContentToken.length != _hashLength ||
            _variantIndexBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength ||
            _collaborator.length != _hashLength
        ) revert WavToken__LengthMismatch();

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

        _prepareWavSuppliesBatch(_hashIdBatch, _cContentToken, _tierMapPages);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCKTN = _cContentToken[
                i
            ];
            uint16 _numToken = _cCKTN.numToken;

            if (_numToken == 0 || _cCKTN.cSupplyVal == 0)
                revert WavToken__NumInputInvalid();

            ContentTokenSearchStruct.s_cContentTokenSearch[
                _hashId
            ] = CContentTokenStorage.CContentToken({
                numToken: _numToken,
                cSupplyVal: _cCKTN.cSupplyVal,
                sPriceUsdVal: _cCKTN.sPriceUsdVal,
                cPriceUsdVal: _cCKTN.cPriceUsdVal,
                sSupplyVal: _cCKTN.sSupplyVal,
                sReserveVal: _cCKTN.sReserveVal,
                cReleaseVal: _cCKTN.cReleaseVal
            });

            _publishCreatorToken(_creatorId, _hashId, _numToken);

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    _collab.s_collaborators[_hashId] = CollaboratorStructStorage
                        .Collaborator({
                            numCollaborator: _collab.numCollaborator,
                            royaltyVal: _collab.royaltyVal
                        });
                    _collab.s_royalties[_hashId] = _royaltyMapBatch[i];
                    _collab.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0) revert WavToken__LengthMismatch();
            }

            if (i == 0) {
                emit CContentTokenPublished(_creatorId, _hashId, _numToken);
            } else {
                uint16 _variantIndex = _variantIndexBatch[i];
                if (_variantIndex == 0) revert WavToken__IndexIssue();
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
    }

    /**
     * @notice Publishes a single user-defined CContentToken.
     * @dev Writes and stores the data of a CContentToken on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _baseHashId The Content Token associated to a derivative Variant.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     * @param _cSupplyVal Unsigned interger containing Content Token price definition.
     * @param _sSupplyVal Unsigned interger containing Content Token supply data.
     * @param _sReserveVal Unsigned interger containing seperate sale reserve values.
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
     * @param _cReleaseVal Unsigned interger containing timestamp publication data.
     * @param _variantIndex Numerical index correlating to the total Variant count of a Content Token.
     * @param _numCollaborator Quantity of defined Collaborators associated with Content Token.
     * @param _royaltyVal Unsigned interger containing collaborator royalty data.
     * @param _royaltyMap Royalty state map of the Content Token numToken index values.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    function publishCVariant(
        address _creatorId,
        bytes32 _baseHashId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _cSupplyVal,
        uint112 _sPriceUsdVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint32 _cPriceUsdVal,
        uint96 _cReleaseVal,
        uint16 _variantIndex,
        uint8 _numCollaborator,
        uint128 _royaltyVal,
        uint256 _royaltyMap,
        uint256[] calldata _tierMapPages
    ) external {
        ReturnValidation.returnIsAuthorized();
        if (_numToken == 0 || _cSupplyVal == 0 || _variantIndex == 0)
            revert WavToken__LengthMismatch();

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

        _publishCreatorToken(_creatorId, _hashId, _numToken);

        _publishCContentTokenWavSupplies(
            _hashId,
            _cSupplyVal,
            _sSupplyVal,
            _sReserveVal,
            _tierMapPages
        );

        if (_numCollaborator > 0) {
            CollaboratorMapStruct.s_collaborators[
                _hashId
            ] = CollaboratorStructStorage.Collaborator({
                numCollaborator: _numCollaborator,
                royaltyVal: _royaltyVal
            });
            CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
            CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
        }

        // Variant association, parent is index[0] of input array
        AssociatedContentStruct.s_variantMap[_baseHashId][
            _variantIndex
        ] = _hashId;
        AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

        emit SVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
    }

    // I MIGHT NEED TO CHANGE ALL OF THE 'calldata' arrays in the batch to 'CContentToken memory cContentToken'

    // the length mismatch of _tierMapPages with _hashId / _numToken.length needs to be addressed via the quantity of _numTokens in each index
    // This is not neccessary obviously in a singular publication function context, but it is clearly needed in a batch instance
    // This alone facilitates the neccessity of a 'publishCContentTokenWavSuppliesBatch()'
    /*function publishCVariantBatch(
        address _creatorId,
        bytes32[] calldata _baseHashId,
        bytes32[] calldata _hashId,
        uint16[] calldata _numToken,
        uint112[] calldata _cSupplyVal,
        uint224[] calldata _sSupplyVal,
        uint160[] calldata _sReserveVal,
        uint32[] calldata _cPriceUsdVal,
        uint96[] calldata _cReserveVal,
        uint16[] calldata _variantIndex,
        uint8[] calldata _numCollaborator,
        uint128[] calldata _royaltyVal,
        uint256[] calldata _royaltyMap,
        uint256[] calldata _tierMapPages
    ) external {
        onlyAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength < 2) revert WavToken__LengthMismatch();
        if(
            _baseHashIdBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength ||
            _priceUsdValBatch.length != _hashLength ||
            _supplyValBatch.length != _hashLength ||
            _releaseValBatch.length != _hashLength ||
            _variantIndexBatch.length != _hashLength ||
            _numCollaboratorBatch.length != _hashLength ||
            _royaltyValBatch.length != _hashLength ||
            _royaltyMapBatch.length != _hashLength
        ) revert WavToken__LengthMismatch();

        // Storage locals
        ContentTokenSearchStorage.ContentTokenSearch storage ContentTokenSearchStruct =
        ContentTokenSearchStorage.contentTokenSearchStorage();

        CollaboratorStructStorage.CollaboratorMap storage CollaboratorMapStruct =
        CollaboratorStructStorage.collaboratorMapStorage();

        AssociatedContentMap.AssociatedContent storage AssociatedContentStruct =
        AssociatedContentMap.associatedContentMap();

        // Reusable temporaries 
        bytes32 _baseHashId;
        bytes32 _hashId;
        uint16 _numToken;
        uint32 _priceUsd;
        uint112 _supplyVal;
        uint96 _releaseVal;
        uint16 _variantIndex;
        uint8 _numCollaborator;
        uint128 _royaltyVal;
        uint256 _royaltyMap;

        for(uint256 i = 0; i < _hashLength;) {
            _baseHashId = _baseHashIdBatch[i];
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _priceUsdVal = _priceUsdValBatch[i];
            _supplyVal = _supplyValBatch[i];
            _releaseVal = _releaseValBatch[i];
            _variantIndex = _variantIndexBatch[i];
            _numCollaborator = _numCollboratorBatch[i];
            _royaltyVal = _royaltyValBatch[i];
            _royaltyMap = _royaltyMapBatch[i];

            // Shared validation
            if(
                _numToken == 0 ||
                _supplyVal == 0 ||
                _variantIndex == 0
            ) {
                WavToken__NumInputInvalid();
            }

            ContentTokenSearchStruct.s_cContentTokenSearch[_hashId] = CContentToken({
                numToken: _numToken,
                cSupplyVal: _cSupplyVal,
                sPriceUsdVal: _sPriceUsdVal,
                cPriceUsdVal: _cPriceUsdVal,
                sSupplyVal: _sSupplyVal,
                sReserveVal: _sReserveVal,
                cReleaseVal: _cReleaseVal
            });

            _publishCreatorToken(
                _creatorId,
                _hashId,
                _numToken
            );

            if(_numCollaborator > 0) {
                CollaboratorMapStruct.s_collaborators[_hashId] = Collaborator({
                    numCollaborator: _numCollaborators,
                    royaltyVal: _royaltyVal
                });
                CollaboratorMapStruct.s_royalties[_hashId] = _royaltyMap;
                CollaboratorMapStruct.s_collaboratorReserve[_hashId][0] = 0;
            }
            // Variant association, parent is index[0] of input array
            AssociatedContentStruct.s_variantMap[_baseHashId][_variantIndex] = _hashId;
            AssociatedContentStruct.s_variantSearch[_hashId] = _baseHashId;

            // Emit per-variant event

            emit CVariantPublished(_creatorId, _baseHashId, _hashId, _variantIndex);
            // unchecked { ++_publishedVariantCount; } **DETERMINE IF WE CAN ENTIRELY REPLACE THIS WITH .LENGTH OR 'i'
            unchecked { ++i; }
        }
        // possibly emit SVariantPublishCount mapping
        emit CVariantBatchPublishedCount(_creatorId, uint16(_hashLength));
    }*/

    // check on function continue on to 'publishCContentTokenBatch'

    /**
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
    function publishCVariantBatch(
        address _creatorId,
        bytes32[] calldata _baseHashIdBatch,
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        CollaboratorStructStorage.Collaborator[] calldata _collaborator,
        uint16[] calldata _variantIndexBatch,
        uint256[] calldata _royaltyMapBatch,
        uint256[] calldata _tierMapPages
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
        ) revert WavToken__LengthMismatch();

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
        uint256 _pageCursor = 0;

        _prepareWavSuppliesBatch(_hashIdBatch, _cContentToken, _tierMapPages);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _baseHashId = _baseHashIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];
            CContentTokenStorage.CContentToken calldata _cCTKN;
            uint16 _numToken = _cCTKN.numToken;
            uint16 _variantIndex = _variantIndexBatch[i];

            if (_numToken == 0 || _cCTKN.cSupplyVal == 0 || _variantIndex == 0)
                revert WavToken__NumInputInvalid();

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

            _publishCreatorToken(_creatorId, _hashId, _numToken);

            if (_collaborator.length > 0) {
                CollaboratorStructStorage.Collaborator
                    calldata _collab = _collaborator[i];
                if (_collab.numCollaborator > 0) {
                    _collab.s_collaborators[_hashId] = CollaboratorStructStorage
                        .Collaborator({
                            numCollaborator: _collab.numCollaborator,
                            royaltyVal: _collab.royaltyVal
                        });
                    _collab.s_royalties[_hashId] = _royaltyMapBatch[i];
                    _collab.s_collaboratorReserve[_hashId][0] = 0;
                }
            } else {
                if (_royaltyMapBatch[i] != 0) revert WavToken__LengthMismatch();
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
    }

    // storage access
    /**
     * @notice Publishes the remaining supply data of a SContentToken.
     * @dev Writes and stores the remaining supply data of two or more CContentToken Variants on the blockchain.
     * @param _hashId Identifier of Content Token being queried.
     * @param _cSupplyVal Collection supply property.
     */
    function _publishSContentTokenWavSupplies(
        bytes32 _hashId,
        uint112 _cSupplyVal
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();
        ContentTokenSupplyMapStruct.s_cWavSupplies[
            _hashId
        ] = publishCWavSuppliesHelper(_cSupplyVal);
    }

    function _publishSContentTokenWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        uint112[] calldata _cSupplyValBatch
    ) internal {
        uint256 _hashLength = _hashIdBatch.length;
        if (_hashLength < 2 || _cSupplyValBatch.length != _hashLength)
            revert WavToken__LengthMismatch();

        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        for (uint256 i = 0; i < _hashLength; ) {
            uint112 _cSupplyVal = _cSupplyValBatch[i];

            ContentTokenSupplyMapStruct.s_cWavSupplies[
                _hashIdBatch[i]
            ] = publishCWavSuppliesHelper(_cSupplyVal);

            unchecked {
                ++i;
            }
        }
    }

    // storage access, will make _publishCContentTokenWavSupplies

    /**
     * @notice Publishes the remaining supply data of or more CContentTokens.
     * @dev Writes and stores the remaining supply data of two or more CContentToken on the blockchain.
     * @param _hashId Identifier of Content Token being queried.
     * @param _cSupplyVal Collection supply property.
     * @param _sSupplyVal Seperate sale supply property.
     * @param _sReserveVal Seperate sale reserve property.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    function _publishCContentTokenWavSupplies(
        bytes32 _hashId,
        uint112 _cSupplyVal,
        uint224 _sSupplyVal,
        uint160 _sReserveVal,
        uint256[] calldata _tierMapPages //uint256[] calldata _stateMapPages,
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        (
            uint112 _sWavSuppliesTier1,
            uint112 _sWavSuppliesTier2,
            uint112 _sWavSuppliesTier3
        ) = publishSWavSuppliesHelper(_sSupplyVal, _sReserveVal);

        // Encode and store each tier
        ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = WavDBC
            .publishCWavSuppliesHelper(_cSupplyVal);
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            1
        ] = _sWavSuppliesTier1;
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            2
        ] = _sWavSuppliesTier2;
        ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][
            3
        ] = _sWavSuppliesTier3;

        uint256 _maxLength = _tierMapPages.length;

        for (uint256 i = 0; i < _maxLength; ) {
            if (i < _maxLength) {
                uint256 _tierPages = _tierMapPages[i];
                if (_tierPages != 0) {
                    // [uint16[i]]??
                    ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                        uint16(i)
                    ] = _tierPages;
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Publishes remaining supply data of two or more CContentToken.
     * @dev Writes and stores remaining supply data of two or more CContentTokens on the blockchain.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _cSupplyValBatch Batch of collection supply properties.
     * @param _sSupplyValBatch Batch of seperate sale supply properties.
     * @param _sReserveValBatch Batch of seperate sale reserve properties.
     * @param _tierMapPages 4-bit state map representing the tier states of numToken index positions.
     */
    function publishCContentTokenWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _cSupplyValBatch,
        uint224[] calldata _sSupplyValBatch,
        uint160[] calldata _sReserveValBatch,
        uint256[] calldata _tierMapPages
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap
            storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                .contentTokenSupplyMapStorage();

        uint256 _hashLength = _hashIdBatch.length;
        if (
            _numTokenBatch.length != _hashLength ||
            _cSupplyValBatch.length != _hashLength ||
            _sSupplyValBatch.length != _hashLength ||
            _sReserveValBatch.length != _hashLength
        ) {
            revert WavToken__LengthMismatch();
        }

        uint256 _pageCursor = 0;

        bytes32 _hashId;
        uint16 _numToken;
        uint112 _cSupplyVal;
        uint224 _sSupplyVal;
        uint160 _sReserveVal;

        for (uint256 i = 0; i < _hashLength; ) {
            _hashId = _hashIdBatch[i];
            _numToken = _numTokenBatch[i];
            _cSupplyVal = _cSupplyValBatch[i];
            _sSupplyVal = _sSupplyValBatch[i];
            _sReserveVal = _sReserveValBatch[i];

            (
                uint112 _sWavSuppliesTier1,
                uint112 _sWavSuppliesTier2,
                uint112 _sWavSuppliesTier3
            ) = publishSWavSuppliesHelper(_sSupplyVal, _sReserveVal);

            ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = WavDBC
                .publishCWavSuppliesHelper(_cSupplyVal);
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
                if (_pageCursor >= _tierMapPages.length) {
                    break;
                }
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

            unchecked {
                ++i;
            }
        }
    }

    /*if(i < _stateMapPages.length) {
                uint256 _statePage = _stateMapPages[i];
                if(_statePage != 0) {
                    ContentTokenSupplyMapStruct.s_enableBitmap[_hashId][uint16(i)] = _statePage;
                }
            }*/

    // ****************Look back over this function*******************
    function _prepareWavSuppliesBatch(
        bytes32[] calldata _hashIdBatch,
        CContentTokenStorage.CContentToken[] calldata _cContentToken,
        uint256[] calldata _tierMapPages
    ) internal {
        uint256 _hashLength = _hashIdBatch.length;
        // Allocate arrays
        uint16[] memory _numTokenBatch = new uint16[](_hashLength);
        uint112[] memory _cSupplyValBatch = new uint112[](_hashLength);
        uint224[] memory _sSupplyValBatch = new uint224[](_hashLength);
        uint160[] memory _sReserveValBatch = new uint160[](_hashLength);
        // Fill arrays from calldata structs
        for (uint256 i = 0; i < _hashLength; ) {
            //_cContentToken[i] calldata _cCKTN.numToken;
            _cContentToken[i] calldata _cCKTN;
            _numTokenBatch[i] = _cCKTN.numToken; // ***I addded this line it was not previously written like this. Check on this***
            _cSupplyValBatch[i] = _cCKTN.cSupplyVal;
            _sSupplyValBatch[i] = _cCKTN.sSupplyVal;
            _sReserveValBatch[i] = _cCKTN.sReserveVal;
            unchecked {
                ++i;
            }
        }
        // Call publishCContentTokenWavSuppliesBatch
        publishCContentTokenWavSuppliesBatch(
            _hashIdBatch,
            _numTokenBatch,
            _cSupplyValBatch,
            _sSupplyValBatch,
            _sReserveValBatch,
            _tierMapPages
        );
    }

    function publishCWavSuppliesHelper(
        uint112 _cSupplyVal
    ) internal pure returns (uint112 _cWavSupplies) {
        (
            ,
            uint112 _initialSupply,
            uint80 _wavReserve,
            uint80 _preRelease
        ) = WavDBC.cSupplyValDecoder(_cSupplyVal);
        _cWavSupplies = WavDBC.remainingSupplyEncoder(
            _initialSupply,
            uint112(_wavReserve),
            uint112(_preRelease)
        );
    }

    function publishSWavSuppliesHelper(
        uint224 _sSupplyVal,
        uint160 _sReserveVal
    )
        internal
        pure
        returns (
            uint112 _sWavSuppliesTier1,
            uint112 _sWavSuppliesTier2,
            uint112 _sWavSuppliesTier3
        )
    {
        (
            ,
            ,
            ,
            ,
            uint112 _initialSupply1,
            uint112 _initialSupply2,
            uint112 _initialSupply3
        ) = WavDBC.sSupplyValDecoder(_sSupplyVal);

        (
            ,
            uint80 _wavReserve1,
            uint80 _wavReserve2,
            uint80 _wavReserve3,
            uint80 _preRelease1,
            uint80 _preRelease2,
            uint80 _preRelease3
        ) = WavDBC.sReserveValDecoder(_sReserveVal);

        _sWavSuppliesTier1 = WavDBC.remainingSupplyEncoder(
            _initialSupply1,
            uint112(_wavReserve1),
            uint112(_preRelease1)
        );
        _sWavSuppliesTier2 = WavDBC.remainingSupplyEncoder(
            _initialSupply2,
            uint112(_wavReserve2),
            uint112(_preRelease2)
        );
        _sWavSuppliesTier3 = WavDBC.remainingSupplyEncoder(
            _initialSupply3,
            uint112(_wavReserve3),
            uint112(_preRelease3)
        );

        return (_sWavSuppliesTier1, _sWavSuppliesTier2, _sWavSuppliesTier3);
    }

    /**
     * @notice Publishes data within the CreatorTokenMap struct during publication of a Content Token.
     * @dev Writes and stores CreatorToken data on the blockchain.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being published.
     * @param _numToken Token index quantity of the Content Token.
     */
    function _publishCreatorToken(
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();

        CreatorTokenStorage.CreatorToken
            storage CreatorTokenStruct = CreatorTokenStorage
                .creatorTokenStructStorage();

        uint256 _contentId = ++CreatorTokenMapStruct.s_ownershipIndex[
            _creatorId
        ];
        CreatorTokenMapStruct.s_publishedTokenData[_hashId][_numToken];
        CreatorTokenStruct.creatorId = _creatorId;
        CreatorTokenStruct.contentId = _contentId;
        CreatorTokenStruct.hashId = _hashId;
        CreatorTokenMapStruct.s_ownershipMap[_creatorId][_contentId][
            _hashId
        ] = _numToken;
    }

    /**
     * @notice Generates a unique hash identifier for a specific track or version.
     * @dev Combines artist's address, content ID, variant number, audio number, and track version to generate a unique bytes32 hash.
     * @param _creatorId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _variantIndex Variant index of Content Token publish context.
     * @return bytes32 The unique hash identifier for the track or version.
     */
    function generateContentHashId(
        address _creatorId,
        uint256 _contentId,
        uint16 _variantIndex
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(_creatorId, _contentId, _variantIndex));
    }
}

/*  CreatorToken memory CRTK = new CreatorToken({
            creatorId: _creatorId,
            contentId: _contentId,
            isOwner: true
        });
        s_musicFiles[_hashId] = WTKN;

        MusicToken MTKN = new MusicToken({
            supplyVal: _supplyVal,
            priceVal: _priceVal,
            releaseVal: _releaseVal,
            numAudio: _numAudio,
            bitVal: _bitVal
        });
        s_musicTokens[_hashId] = MTKN; */

// storage access, will make _publishCContentTokenWavSupplies
/* function publishCContentTokenWavSupplies(
        bytes32 _hashId,
        uint112 _supplyVal
        uint112 _sInitialSupply,
        uint80 _sWavR,
        uint80 _sPreSaleR
    ) internal {
        ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
        ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

        (
            ,
            uint112 _initialSupply,
            uint80 _wavSupply,
            uint80 _preRelease
        ) = WavDBC.cSupplyValDecoder(_supplyVal);
        
        (
            ,
            uint112 _initialSupply1,
            uint112 _initialSupply2,
            uint112 _initialSupply3
        ) = WavDBC.sInitialSupplyDecoder(_sInitialSupply);

        (
            ,
            uint80 _wavReserve1,
            uint80 _wavReserve2,
            uint80 _wavReserve3
        ) = WavDBC.sWavRDecoder(_sWavR);

        (
            ,
            uint80 _preRelease1,
            uint80 _preRelease2,
            uint80 _preRelease3
        ) = WavDBC.sPreSaleRDecoder(_sPreSaleR);

        // Encode and store each tier
        s_cWavSupplies[_hashId] = WavDBC.remainingSupplyEncoder(_initialSupply, uint112(_wavReserve), uint112(_preRelease));
        s_sWavSupplies[_hashId][1] = WavDBC.remainingSupplyEncoder(_initialSupply1, uint112(_wavReserve1), uint112(_preRelease1));
        s_sWavSupplies[_hashId][2] = WavDBC.remainingSupplyEncoder(_initialSupply2, uint112(_wavReserve2), uint112(_preRelease2));
        s_sWavSupplies[_hashId][3] = WavDBC.remainingSupplyEncoder(_initialSupply3, uint112(_wavReserve3), uint112(_preRelease3));
    } */
