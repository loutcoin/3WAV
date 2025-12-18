// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../../src/3WAVi__Helpers/ReturnValidation.sol";
// ***To be 'granular-ized'***
//import {ReturnMapping} from "../../../../src/3WAVi__Helpers/ReturnMapping.sol";
import {ReleaseDBC} from "../../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";
import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
import {
    SContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

// Trying to totally consolidate storage access
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

        // Load hourStamp
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint96 _disablePeriod = _disablePeriodBatch[i];

            /*uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(
                _hashId
            );*/

            uint96 _releaseVal = ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cReleaseVal;

            // cContentToken Branch
            if (_releaseVal != 0) {
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
                /*CContentTokenStorage.CContentToken
                    storage CContentTokenStruct = CContentTokenStorage
                        .cContentTokenStructStorage();
                CContentTokenStruct.cReleaseVal = _updatedReleaseVal;*/

                emit PostManualEndRelease(_hashId, _updatedEndRelease);

                unchecked {
                    ++i;
                }
                continue;
            }

            //_releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);

            // was "uint96 _releaseVal" but was already declared
            _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            if (_releaseVal != 0) {
                // decode
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
                /*SContentTokenStorage.SContentToken
                    storage SContentTokenStruct = SContentTokenStorage
                        .sContentTokenStructStorage();
                SContentTokenStruct.releaseVal = _updatedReleaseVal;*/

                emit PostManualEndRelease(_hashId, _updatedEndRelease);

                unchecked {
                    ++i;
                }
                continue;
            }
        }
    }
}
