// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {ReleaseDBC} from "../../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";

import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    ContentTokenSearchStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

contract PreReleaseState {
    event PRState(bytes32 indexed _hashId, uint8 indexed _inputState);

    error PreReleaseState__InputInvalid();
    error PreReleaseState__InputStateInEffect();
    error PreReleaseState__InputError404();

    /**
     * @notice Allows manual intervention to pause or resume an active preRelease sale.
     * @dev The input state is '0' by default. An input state of '1' indicates a paused sale state.
     * @param _hashId Identifier of Content Token being queried.
     * @param _inputState Value affecting sale state of Content Token.
     */
    function preReleaseState(bytes32 _hashId, uint8 _inputState) external {
        ReturnValidation.returnIsAuthorized();

        if (_inputState > 1) revert PreReleaseState__InputInvalid();

        // cContentToken branch
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

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
            ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

            // Only allow pause if preSale is currently active,
            // only allow resume if preSale is paused
            if (
                (_inputState == 1 && _pausedAt != 0) ||
                (_inputState == 0 && _pausedAt != 1)
            ) revert PreReleaseState__InputStateInEffect();

            // Activate _pausedAt state and encode
            uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
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
            return;
        }

        // sContentToken branch
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
            ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

            // Only allow pause if preSale is currently active, only allow resume if preSale is paused
            if (
                (_inputState == 1 && _pausedAt != 0) ||
                (_inputState == 0 && _pausedAt != 1)
            ) revert PreReleaseState__InputStateInEffect();

            // Activate _pausedAt state and encode
            uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
                _startRelease,
                _endRelease,
                _preRelease,
                _inputState
            );

            ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal = _updatedReleaseVal;

            emit PRState(_hashId, _inputState);

            return;
        }
        // Content Token not found in either storage location
        revert PreReleaseState__InputError404();
    }
}
