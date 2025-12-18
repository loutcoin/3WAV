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

contract PostEndRelease {
    event TestReleaseData(
        uint96 indexed _startRelease,
        uint96 indexed _endRelease,
        uint96 _preRelease,
        uint8 _pausedAt
    );

    event TestReleaseData2(uint96 indexed _releaseVal);

    event PostManualEndRelease(
        bytes32 indexed _hashId,
        uint96 indexed _updatedEndRelease
    );

    error PostEndRelease__InputInvalid();
    error PostEndRelease__Immutable();
    error PostEndRelease__InputError404();
    /**
     * @notice Allows definition of an _endRelease date for a Content Token post-publication.
     * @dev Mandatory minimum of 72-hour window before _endRelease may be executed.
     * @param _hashId Identifier of Content Token being queried.
     * @param _disablePeriod Quantity of hours until _endRelease takes effect.
     */
    function postManualEndRelease(
        bytes32 _hashId,
        uint96 _disablePeriod
    ) external {
        ReturnValidation.returnIsAuthorized();

        // Minimum enforced _endRelease execution window (72 hours)
        if (_disablePeriod < 72) {
            revert PostEndRelease__InputInvalid();
        }

        // load current hour stamp once
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        // cContentToken Branch
        /*uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(
            _hashId
        );*/

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        uint96 _releaseVal = ContentTokenSearchStruct
            .s_cContentTokenSearch[_hashId]
            .cReleaseVal;

        if (_releaseVal != 0) {
            (
                uint96 _startRelease,
                uint96 _endRelease,
                uint96 _preRelease,
                uint8 _pausedAt
            ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

            emit TestReleaseData(
                _startRelease,
                _endRelease,
                _preRelease,
                _pausedAt
            );

            // Only allow scheduling if _endRelease undefined
            if (_endRelease != 0) revert PostEndRelease__Immutable();

            // Compute _updatedEndRelease
            uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

            // Create, validate, encode _updatedReleaseVal
            uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
                _startRelease,
                _updatedEndRelease,
                _preRelease,
                _pausedAt
            );

            emit TestReleaseData2(_updatedReleaseVal);

            // Write into cContentToken storage
            ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashId]
                .cReleaseVal = _updatedReleaseVal;
            /*CContentTokenStorage.CContentToken
                storage CContentTokenStruct = CContentTokenStorage
                    .cContentTokenStructStorage();
            CContentTokenStruct.cReleaseVal = _updatedReleaseVal;*/

            emit PostManualEndRelease(_hashId, _updatedEndRelease);
            return;
        }
        // sContentToken branch
        /*_releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);*/

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
            if (_endRelease != 0) revert PostEndRelease__Immutable();

            // Compute _updatedEndRelease
            uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

            // Create, validate, encode _updatedReleaseVal
            uint96 _updatedReleaseVal = ReleaseDBC._cReleaseValEncoder6(
                _startRelease,
                _updatedEndRelease,
                _preRelease,
                _pausedAt
            );
            /*SContentTokenStorage.SContentToken
                storage SContentTokenStruct = SContentTokenStorage
                    .sContentTokenStructStorage();
            SContentTokenStruct.releaseVal = _updatedReleaseVal;*/
            ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal = _updatedReleaseVal;

            emit PostManualEndRelease(_hashId, _updatedEndRelease);
            return;
        }
        // Content Token not found in either storage location
        revert PostEndRelease__InputError404();
    }
}
