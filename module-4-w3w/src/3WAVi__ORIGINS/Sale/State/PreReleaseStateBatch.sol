// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../../src/3WAVi__Helpers/ReturnValidation.sol";

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
    event PRStateBatchIndex(bytes32 indexed _hashId, uint8 indexed _inputState);
    event PRStateBatchQuantity(uint256 _operationCount);

    error PreReleaseStateBatch__InputStateInEffect();

    /**
     * @notice Allows manual intervention to pause or resume active preRelease sales.
     * @dev The input state is '0' by default. An input state of '1' indicates a paused sale state.
     * @param _hashIdBatch Identifier batch of the Content Tokens being queried.
     * @param _inputStateBatch Values affecting the sale states of Content Tokens.
     */
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
                // Decode cReleaseVal
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseBatchDBC._cReleaseValDecoder6(_releaseVal);

                // Only allow pause if preSale is currently active,
                // only allow resume if preSale is paused
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

                emit PRStateBatchIndex(_hashId, _inputState);

                unchecked {
                    ++i;
                }
                continue;
            }

            _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            if (_releaseVal != 0) {
                // Decode cReleaseVal
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

                emit PRStateBatchIndex(_hashId, _inputState);

                unchecked {
                    ++i;
                }
                continue;
            }
        }
        emit PRStateBatchQuantity(_inputStateBatch.length);
    }
}
