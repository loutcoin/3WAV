// SPDX-License-Identifier: MIT
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

contract PostEndReleaseBatch {
    event PostManualEndRelease(
        bytes32 indexed _hashId,
        uint96 indexed _updatedEndRelease
    );

    error PostEndReleaseBatch__LengthMismatch();
    error PostEndReleaseBatch__InputInvalid();
    error PostEndReleaseBatch__Immutable();

    /**
     * @notice Allows definition of _endRelease date for a batch of Content Tokens post-publication.
     * @dev Mandatory minimum of 72-hour window before _endRelease may be executed.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _disablePeriodBatch Quantity of hours until _endRelease takes effect for each hash.
     */
    function postManualEndReleaseBatch(
        bytes32[] calldata _hashIdBatch,
        uint96[] calldata _disablePeriodBatch
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if (_hashLength < 2 || _disablePeriodBatch.length != _hashLength)
            revert PostEndReleaseBatch__LengthMismatch();

        for (uint256 i = 0; i < _hashLength; ) {
            if (_disablePeriodBatch[i] < 72)
                revert PostEndReleaseBatch__InputInvalid();

            unchecked {
                ++i;
            }
        }

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint96 _disablePeriod = _disablePeriodBatch[i];

            uint96 _releaseVal = ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cReleaseVal;

            // cContentToken Branch

            if (_releaseVal != 0) {
                // Decode cReleaseVal
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                // Only allow scheduling if _endRelease undefined
                if (_endRelease != 0) revert PostEndReleaseBatch__Immutable();

                // Compute _updatedEndRelease
                uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

                // Create, validate, encode _updatedReleaseVal
                uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
                    _startRelease,
                    _updatedEndRelease,
                    _preRelease,
                    _pausedAt
                );

                // Write into cContentToken storage
                ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal = _updatedReleaseVal;

                emit PostManualEndRelease(_hashId, _updatedEndRelease);

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
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                // Only allow scheduling if _endRelease undefined
                if (_endRelease != 0) revert PostEndReleaseBatch__Immutable();

                // Compute _updatedEndRelease
                uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

                // Create, validate, encode _updatedReleaseVal
                uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
                    _startRelease,
                    _updatedEndRelease,
                    _preRelease,
                    _pausedAt
                );

                ContentTokenSearchStruct
                    .s_sContentTokenSearch[_hashId]
                    .releaseVal = _updatedReleaseVal;

                emit PostManualEndRelease(_hashId, _updatedEndRelease);

                unchecked {
                    ++i;
                }
                continue;
            }
        }
    }
}
