// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnContentToken
} from "../../../src/3WAVi__Helpers/ReturnMapping/ReturnContentToken.sol";
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library ReleaseDBC {
    error ReleaseDBC__ReleaseInputIssue();
    error ReleaseDBC__NumInputInvalid();
    error ReleaseDBC__InputError404();
    /**
     * @notice Encodes four raw values related to the cReleaseVal Content Token property.
     * @dev Function called by script to correctly format stored cReleaseVal data.
     *      Function Selector: 0x6e8c4a2d
     * @param _startRelease The intended official publication date of a Content Token.
     * @param _endRelease An optional disable date for official sale of a Content Token.
     * @param _preRelease An optional timestamp for an enabled preSale period to occur.
     * @param _pausedAt Variable sale-state property.
     */
    function _cReleaseValEncoder6(
        uint96 _startRelease,
        uint96 _endRelease,
        uint96 _preRelease,
        uint8 _pausedAt
    ) internal pure returns (uint96 _releaseVal) {
        //uint96 _hourStamp = ReturnValidation._returnHourStamp();
        if (
            //_startRelease < _hourStamp ||
            //_endRelease < _hourStamp ||
            //_preRelease < _hourStamp ||
            _pausedAt > 1 ||
            _startRelease >= NumericalConstants.CRELEASE_6_MAX ||
            _endRelease >= NumericalConstants.CRELEASE_6_MAX ||
            _preRelease >= NumericalConstants.CRELEASE_6_MAX
        ) {
            revert ReleaseDBC__ReleaseInputIssue();
        }
        _releaseVal += _startRelease * NumericalConstants.SHIFT_14__96;
        _releaseVal += _endRelease * NumericalConstants.SHIFT_8__96; // SHIFT_7__96
        _releaseVal += _preRelease * NumericalConstants.SHIFT_1__96;
        _releaseVal += _pausedAt;
        return _releaseVal;
    }

    /**
     * @notice Decodes underlying values within the releaseVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within releaseVal.
     *      Function Selector: 0x70f143f2
     * @param _releaseVal Unsigned interger containing timestamp publication data.
     */
    function _cReleaseValDecoder6(
        uint96 _releaseVal
    )
        internal
        pure
        returns (
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt
        )
    {
        if (
            _releaseVal < NumericalConstants.SHIFT_19__96 ||
            _releaseVal > NumericalConstants.SHIFT_20__96
        ) {
            revert ReleaseDBC__NumInputInvalid();
        }
        _startRelease = _releaseVal / NumericalConstants.SHIFT_14__96;
        _endRelease =
            (_releaseVal / NumericalConstants.SHIFT_8__96) %
            NumericalConstants.SHIFT_7__96;
        _preRelease =
            (_releaseVal / NumericalConstants.SHIFT_1__96) %
            NumericalConstants.SHIFT_7__96;
        _pausedAt = uint8(_releaseVal % NumericalConstants.SHIFT_1__96);

        return (_startRelease, _endRelease, _preRelease, _pausedAt);
    }

    /**
     * @notice Validates and returns cReleaseVal data specific to a Content Token.
     * @dev Authenticates cReleaseVal data associated to provided hashId input for further use.
     *      Function Selector: 0xc40e145a
     * @param _hashId Identifier of Content Token being queried.
     */
    function validateContentTokenReleaseData(
        bytes32 _hashId
    )
        external
        view
        returns (
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt
        )
    {
        uint96 _releaseVal = ReturnContentToken.returnCContentTokenReleaseVal(
            _hashId
        );

        if (_releaseVal != 0) {
            // IF logic here
            (
                _startRelease,
                _endRelease,
                _preRelease,
                _pausedAt
            ) = _cReleaseValDecoder6(_releaseVal);
            return (_startRelease, _endRelease, _preRelease, _pausedAt);
        }

        _releaseVal = ReturnContentToken.returnSContentTokenReleaseVal(_hashId);

        if (_releaseVal != 0) {
            // IF logic here
            (
                _startRelease,
                _endRelease,
                _preRelease,
                _pausedAt
            ) = _cReleaseValDecoder6(_releaseVal);
            return (_startRelease, _endRelease, _preRelease, _pausedAt);
        }

        revert ReleaseDBC__InputError404();
    }
}
