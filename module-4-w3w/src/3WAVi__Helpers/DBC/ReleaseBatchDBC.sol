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

library ReleaseBatchDBC {
    error ReleaseBatchDBC__ReleaseInputIssue();
    error ReleaseBatchDBC__NumInputInvalid();
    error ReleaseBatchDBC__LengthValIssue();
    error ReleaseBatchDBC__MinEncodedValueInvalid();
    error ReleaseBatchDBC__InputError404();
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
        if (
            _pausedAt > 1 ||
            _startRelease >= NumericalConstants.CRELEASE_6_MAX ||
            _endRelease >= NumericalConstants.CRELEASE_6_MAX ||
            _preRelease >= NumericalConstants.CRELEASE_6_MAX
        ) {
            revert ReleaseBatchDBC__ReleaseInputIssue();
        }
        _releaseVal += _startRelease * NumericalConstants.SHIFT_14__96;
        _releaseVal += _endRelease * NumericalConstants.SHIFT_8__96;
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
            _releaseVal <= NumericalConstants.SHIFT_19__96 ||
            _releaseVal >= NumericalConstants.SHIFT_20__96
        ) {
            revert ReleaseBatchDBC__NumInputInvalid();
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
     * @notice Encodes a batch of four input values related to multiple cReleaseVal properties.
     * @param _startReleaseBatch Array of official Content Token publication dates.
     * @param _endReleaseBatch Array of Content Token optional termination of sale timestamps.
     * @param _preReleaseBatch Array of Content Token optional preSale period timestamps.
     * @param _pausedAtBatch Array of variable sale-state properties.
     *
     */
    function _cReleaseValEncoderBatch6(
        uint96[] calldata _startReleaseBatch,
        uint96[] calldata _endReleaseBatch,
        uint96[] calldata _preReleaseBatch,
        uint8[] calldata _pausedAtBatch
    ) internal pure returns (uint96[] memory _releaseValBatch) {
        uint96 _releaseLength = uint96(_startReleaseBatch.length);

        if (
            _releaseLength != _endReleaseBatch.length ||
            _releaseLength != _preReleaseBatch.length ||
            _releaseLength != _pausedAtBatch.length
        ) {
            revert ReleaseBatchDBC__LengthValIssue();
        }

        if (_releaseLength == 0) {
            return new uint96[](0);
        }

        for (uint96 i = 0; i < _releaseLength; ) {
            uint96 _str = _startReleaseBatch[i];
            uint96 _end = _endReleaseBatch[i];
            uint96 _pre = _preReleaseBatch[i];
            uint8 _paused = _pausedAtBatch[i];

            if (
                _str >= NumericalConstants.SHIFT_7__96 ||
                _end >= NumericalConstants.SHIFT_7__96 ||
                _pre >= NumericalConstants.SHIFT_7__96 ||
                _paused > 1
            ) {
                revert ReleaseBatchDBC__ReleaseInputIssue();
            }
            _releaseValBatch[i] =
                _str *
                NumericalConstants.SHIFT_14__96 +
                _end *
                NumericalConstants.SHIFT_8__96 +
                _pre *
                NumericalConstants.SHIFT_1__96 +
                uint96(_paused);

            unchecked {
                ++i;
            }
        }
        return _releaseValBatch;
    }

    /**
     * @notice Encodes a batch of four input values related to multiple cReleaseVal properties.
     * @param _startReleaseBatch Array of official Content Token publication dates.
     * @param _endReleaseBatch Array of Content Token optional termination of sale timestamps.
     * @param _preReleaseBatch Array of Content Token optional preSale period timestamps.
     * @param _pausedAtBatch Array of variable sale-state properties.
     *
     */
    function _cReleaseValEncoderMemoryBatch6(
        uint96[] memory _startReleaseBatch,
        uint96[] memory _endReleaseBatch,
        uint96[] memory _preReleaseBatch,
        uint8[] memory _pausedAtBatch
    ) internal pure returns (uint96[] memory _releaseValBatch) {
        uint96 _releaseLength = uint96(_startReleaseBatch.length);

        if (
            _releaseLength != _endReleaseBatch.length ||
            _releaseLength != _preReleaseBatch.length ||
            _releaseLength != _pausedAtBatch.length
        ) {
            revert ReleaseBatchDBC__LengthValIssue();
        }

        if (_releaseLength == 0) {
            return new uint96[](0);
        }

        for (uint96 i = 0; i < _releaseLength; ) {
            uint96 _str = _startReleaseBatch[i];
            uint96 _end = _endReleaseBatch[i];
            uint96 _pre = _preReleaseBatch[i];
            uint8 _paused = _pausedAtBatch[i];

            if (
                _str >= NumericalConstants.SHIFT_7__96 ||
                _end >= NumericalConstants.SHIFT_7__96 ||
                _pre >= NumericalConstants.SHIFT_7__96 ||
                _paused > 1
            ) {
                revert ReleaseBatchDBC__ReleaseInputIssue();
            }
            _releaseValBatch = new uint96[](_releaseLength);
            _releaseValBatch[i] =
                _str *
                NumericalConstants.SHIFT_14__96 +
                _end *
                NumericalConstants.SHIFT_8__96 +
                _pre *
                NumericalConstants.SHIFT_1__96 +
                uint96(_paused);

            unchecked {
                ++i;
            }
        }
        return _releaseValBatch;
    }

    /**
     * @notice Decodes underlying values within releaseValBatch.
     * @dev Function called by script to decode underlying data stored within releaseValBatch.
     *      Function Selector: 0x70f143f2
     * @param _releaseValBatch Batch of unsigned intergers containing timestamp publication data.
     */
    function _cReleaseValDecoderBatch6(
        uint96[] calldata _releaseValBatch
    )
        internal
        pure
        returns (
            uint96[] memory _startReleaseBatch,
            uint96[] memory _endReleaseBatch,
            uint96[] memory _preReleaseBatch,
            uint8[] memory _pausedAtBatch
        )
    {
        uint96 _releaseLength = uint96(_releaseValBatch.length);

        if (_releaseLength < 2) {
            revert ReleaseBatchDBC__LengthValIssue();
        }

        _startReleaseBatch = new uint96[](_releaseLength);
        _endReleaseBatch = new uint96[](_releaseLength);
        _preReleaseBatch = new uint96[](_releaseLength);
        _pausedAtBatch = new uint8[](_releaseLength);

        for (uint256 i = 0; i < _releaseLength; ) {
            uint96 _packed = _releaseValBatch[i];

            if (
                _packed <= NumericalConstants.SHIFT_19__96 ||
                _packed >= NumericalConstants.SHIFT_20__96
            ) {
                revert ReleaseBatchDBC__MinEncodedValueInvalid();
            }
            // inline decode exactly as in cReleaseValDecoder6
            _startReleaseBatch[i] = _packed / NumericalConstants.SHIFT_14__96;
            _endReleaseBatch[i] =
                (_packed / NumericalConstants.SHIFT_8__96) %
                NumericalConstants.SHIFT_7__96;
        }
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

        revert ReleaseBatchDBC__InputError404();
    }

    /**
     * @notice Validates and returns a dynamic quantity of cReleaseVal data associated with Content Tokens.
     * @dev Authenticates cReleaseVal data associated to provided hashId values for further use.
     *      Function Selector: 0x341f7875
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     */
    function validateContentTokenReleaseDataBatch(
        bytes32[] calldata _hashIdBatch
    )
        external
        view
        returns (
            uint96[] memory _startRelease,
            uint96[] memory _endRelease,
            uint96[] memory _preRelease,
            uint8[] memory _pausedAt
        )
    {
        uint256 _hashLength = _hashIdBatch.length;
        _startRelease = new uint96[](_hashLength);
        _endRelease = new uint96[](_hashLength);
        _preRelease = new uint96[](_hashLength);
        _pausedAt = new uint8[](_hashLength);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];

            uint96 _packed = ReturnContentToken.returnCContentTokenReleaseVal(
                _hashId
            );

            if (_packed == 0) {
                _packed = ReturnContentToken.returnSContentTokenReleaseVal(
                    _hashId
                );
                if (_packed == 0) revert ReleaseBatchDBC__InputError404();
            }

            (
                _startRelease[i],
                _endRelease[i],
                _preRelease[i],
                _pausedAt[i]
            ) = _cReleaseValDecoder6(_packed);

            unchecked {
                ++i;
            }
        }
    }
}
