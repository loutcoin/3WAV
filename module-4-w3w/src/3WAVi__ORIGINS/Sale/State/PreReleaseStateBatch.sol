// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../../src/3WAVi__Helpers/ReturnValidation.sol";
// ***To be 'granular-ized'***
//import {ReturnMapping} from "../../../../src/3WAVi__Helpers/ReturnMapping.sol";
import {
    ReleaseBatchDBC
} from "../../../../src/3WAVi__Helpers/DBC/ReleaseBatchDBC.sol";
import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
import {
    SContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
import {
    ContentTokenSearchStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

contract PreReleaseStateBatch {
    event PRState(bytes32 indexed _hashId, uint8 indexed _inputState);
    event PRStateBatch(bytes32[] _hashIdBatch, uint8[] _inputStateBatch);

    error PreReleaseStateBatch__InputStateInEffect();

    /*
     * @notice Allows manual intervention to pause or resume a plurality of active preRelease sales
     * @dev The input state is '0' by default. An input state of '1' indicates a paused sale state.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _inputStateBatch Batch of values affecting PreRelease sale states of Content Tokens.
     */
    /*function preReleaseStateBatch(
        bytes32[] calldata _hashIdBatch,
        uint8[] calldata _inputStateBatch
    ) external {
        //ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (_hashLength == 0 || _inputStateBatch.length != _hashLength)
            revert PreReleaseStateBatch__LengthMismatch();

        // just added this one (delete this comment next you see this after basic verifications)
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        // Validate input states
        for (uint256 i = 0; i < _inputStateBatch.length; ) {
            if (_inputStateBatch[i] > 1)
                revert PreReleaseStateBatch__InputInvalid();
            unchecked {
                ++i;
            }
        }
        // Batch releaseVal data validation
        (
            uint96[] memory _startReleaseBatch,
            uint96[] memory _endReleaseBatch,
            uint96[] memory _preReleaseBatch,
            uint8[] memory _pausedAtBatch
        ) = ReleaseBatchDBC.validateContentTokenReleaseDataBatch(_hashIdBatch);

        // Build updated _pausedAt batch
        uint8[] memory _updatedPausedAtBatch = new uint8[](_hashLength);

        for (uint i = 0; i < _inputStateBatch.length; ) {
            uint8 _pausedAt = _pausedAtBatch[i];
            uint8 _inputState = _inputStateBatch[i];

            // Only allow pause if preSale is currently active, only allow resume if preSale is paused
            if (
                (_inputState == 1 && _pausedAt != 0) ||
                (_inputState == 0 && _pausedAt != 1)
            ) {
                revert PreReleaseStateBatch__InputStateInEffect();
            }
            _updatedPausedAtBatch[i] = _inputState;
            unchecked {
                ++i;
            }
        }

        emit TestPausedAtArray(_updatedPausedAtBatch);

        uint96[] memory _updatedReleaseValBatch = new uint96[](
            _inputStateBatch.length
        );

        // Encode releaseVal data in batch
        _updatedReleaseValBatch = ReleaseBatchDBC
            ._cReleaseValEncoderMemoryBatch6(
                _startReleaseBatch,
                _endReleaseBatch,
                _preReleaseBatch,
                _updatedPausedAtBatch
            );

        emit WeMadeItThisFar(true);

        // Write back into correct branch by checking storage presence
        for (uint256 i = 0; i < _hashLength; ++i) {
            bytes32 _hashId = _hashIdBatch[i];
            uint96 _updatedReleaseVal = _updatedReleaseValBatch[i];

            /*uint96 _returnData = ReturnMapping.returnCContentTokenReleaseVal(
                _hashId
            );*/
    /*uint96 _releaseVal = ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cReleaseVal;

            emit ItIsWorking200000(_releaseVal);

            if (_releaseVal != 0) {
                // Write into cContentToken storage
                ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal = _updatedReleaseVal;
                /*unchecked {
                    ++i;
                }*/
    /*    continue;
            }
            // make sure can just reuse _returnData
            //_returnData = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
            _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            emit ItIsWorking100000(_releaseVal);

            if (_releaseVal != 0) {
                ContentTokenSearchStruct
                    .s_sContentTokenSearch[_hashId]
                    .releaseVal = _updatedReleaseVal;
                /*unchecked {
                    ++i;
                }*/
    /*   continue;
            }
            // Should not happen because validateContentTokenReleaseDataBatch should revert
            // In place just as simple extra defensive check
            revert PreReleaseStateBatch__InputError404();
        }
        // Emit single batch event
        emit PRStateBatch(_hashIdBatch, _inputStateBatch);
    }*/

    function preReleaseStateBatch(
        bytes32[] calldata _hashIdBatch,
        uint8[] calldata _inputStateBatch
    ) external {
        ReturnValidation.returnIsAuthorized();
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _hashIdBatch.length; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint8 _inputState = _inputStateBatch[i];

            uint96 _releaseVal = ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cReleaseVal;
            if (_releaseVal != 0) {
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseBatchDBC._cReleaseValDecoder6(_releaseVal);

                // Only allow pause if preSale is currently active, only allow resume if preSale is paused
                if (
                    (_inputState == 1 && _pausedAt != 0) ||
                    (_inputState == 0 && _pausedAt != 1)
                ) revert PreReleaseStateBatch__InputStateInEffect();
                // Activate _pausedAt state and encode
                uint96 _updatedReleaseVal = ReleaseBatchDBC
                    ._cReleaseValEncoder6(
                        _startRelease,
                        _endRelease,
                        _preRelease,
                        _inputState
                    );

                // Write into cContentToken storage
                ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal = _updatedReleaseVal;

                emit PRState(_hashId, _inputState);

                unchecked {
                    ++i;
                }
                continue;
            }

            _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            if (_releaseVal != 0) {
                // Decode
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseBatchDBC._cReleaseValDecoder6(_releaseVal);

                // Only allow pause if preSale is currently active, only allow resume if preSale is paused
                if (
                    (_inputState == 1 && _pausedAt != 0) ||
                    (_inputState == 0 && _pausedAt != 1)
                ) revert PreReleaseStateBatch__InputStateInEffect();

                // Activate _pausedAt state and encode
                uint96 _updatedReleaseVal = ReleaseBatchDBC
                    ._cReleaseValEncoder6(
                        _startRelease,
                        _endRelease,
                        _preRelease,
                        _inputState
                    );

                ContentTokenSearchStruct
                    .s_sContentTokenSearch[_hashId]
                    .releaseVal = _updatedReleaseVal;

                emit PRState(_hashId, _inputState);
                unchecked {
                    ++i;
                }
                continue;
            }
        }
    }
}
