// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library SupplyDBC {
    error SupplyDBC__SupplyAllocationError();
    error SupplyDBC__MinEncodedValueInvalid();
    error SupplyDBC__NumInputInvalid();

    /**
     * @notice Encodes four raw values related to the 33-digit cSupplyVal ContentToken property.
     * @dev Function called by script to correctly format stored cSupplyVal data.
     *      Function Selector: 0x35a93e5a
     * @param _totalSupply Maximum supply value defined for a CContentToken.
     * @param _initialSupply Initial supply value defined for a CContentToken.
     * @param _wavReserve Optional Content Token allocation reserve value.
     * @param _preSupply Optional Content Token pre-sale reserve value.
     */
    function _cSupplyValEncoder(
        uint112 _totalSupply,
        uint112 _initialSupply,
        uint112 _wavReserve,
        uint112 _preSupply
    ) internal pure returns (uint112 _cSupplyVal) {
        if (
            // _totalSupply must be at least 1 and no more than 10 digits
            _totalSupply < 1 ||
            _totalSupply >= NumericalConstants.SHIFT_11 ||
            // _initialSupply can be no more than 10 digits or exceed _totalSupply
            _initialSupply >= NumericalConstants.SHIFT_11 ||
            _initialSupply > _totalSupply ||
            // _wavReserve and _preSupply cannot be exceed 6 numerical digits
            _wavReserve >= NumericalConstants.SHIFT_7 ||
            _preSupply >= NumericalConstants.SHIFT_7 || // possibly redundant
            // _preSupply capped at 40% of _totalSupply, _wavReserve + _preSupply <= 100%
            _preSupply > NumericalConstants.CPRE_SUPPLY_MAXIMUM ||
            (_wavReserve + _preSupply) > NumericalConstants.SHIFT_7
            // _totalSupply allocations should not exceed 100% the value of _totalSupply
        ) {
            revert SupplyDBC__SupplyAllocationError();
        }

        _cSupplyVal = NumericalConstants.SHIFT_33;

        _cSupplyVal += _totalSupply * NumericalConstants.SHIFT_23;
        _cSupplyVal += _initialSupply * NumericalConstants.SHIFT_13;
        _cSupplyVal += _wavReserve * NumericalConstants.SHIFT_7;
        _cSupplyVal += _preSupply;
        return _cSupplyVal;
    }

    /**
     * @notice Decodes encoded input into its underlying raw values for the cSupplyVal ContentToken property.
     * @dev Function called by script to decode underlying data stored within cSupplyVal data.
     * @param _cSupplyVal Encoded cSupplyVal ContentToken property.
     */
    function _cSupplyValDecoder(
        uint112 _cSupplyVal
    )
        internal
        pure
        returns (
            uint112 _totalSupply,
            uint112 _initialSupply,
            uint112 _wavReserve,
            uint112 _preSupply
        )
    {
        // Was '_cSupplyVal < NumericalConstants.SHIFT33' however _totalSupply should at least be '1'
        if (_cSupplyVal < NumericalConstants.MIN_CSUPPLY) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }

        // Extract fields using the same shifts as the encoder
        _totalSupply = uint112(
            (_cSupplyVal / NumericalConstants.SHIFT_23) %
                NumericalConstants.SHIFT_11
        );
        _initialSupply = uint112(
            (_cSupplyVal / NumericalConstants.SHIFT_13) %
                NumericalConstants.SHIFT_11
        );
        _wavReserve = uint112(
            (_cSupplyVal / NumericalConstants.SHIFT_7) %
                NumericalConstants.SHIFT_7
        );
        _preSupply = uint112(_cSupplyVal % NumericalConstants.SHIFT_7);

        return (_totalSupply, _initialSupply, _wavReserve, _preSupply);
    }

    /**
     * @notice Encodes seven raw values related to the 63-digit cSupplyVal ContentToken property.
     * @dev Function called by script to correctly format stored sSupplyVal data.
     * @param _zeroVal Indicates presence of zero value.
     * @param _seperateTSupply1 The first maximum seperate sale supply value defined of a CContentToken.
     * @param _seperateTSupply2 The second maximum seperate sale supply value defined of a CContentToken.
     * @param _seperateTSupply3 The third maximum seperate sale supply value defined of a CContentToken.
     * @param _seperateISupply1 The first seperate sale initial supply value defined of a CContentToken.
     * @param _seperateISupply2 The second seperate sale initial supply value defined of a CContentToken.
     * @param _seperateISupply3 The third seperate sale initial supply value defined of a CContentToken.
     */
    function _sSupplyValEncoder(
        uint8 _zeroVal,
        uint112 _seperateTSupply1,
        uint112 _seperateTSupply2,
        uint112 _seperateTSupply3,
        uint112 _seperateISupply1,
        uint112 _seperateISupply2,
        uint112 _seperateISupply3
    ) internal pure returns (uint224 _sSupplyVal) {
        if (
            _zeroVal > 1 ||
            _seperateTSupply1 >= NumericalConstants.SHIFT_11 ||
            _seperateTSupply2 >= NumericalConstants.SHIFT_11 ||
            _seperateTSupply3 >= NumericalConstants.SHIFT_11 ||
            _seperateTSupply1 >= NumericalConstants.SHIFT_11 ||
            _seperateTSupply2 >= NumericalConstants.SHIFT_11 ||
            _seperateTSupply3 >= NumericalConstants.SHIFT_11
        ) {
            revert SupplyDBC__NumInputInvalid();
        }

        _sSupplyVal = NumericalConstants.SHIFT_63__224;

        if (_zeroVal == 1) {
            _sSupplyVal += NumericalConstants.SHIFT_61__224;
        }

        _sSupplyVal +=
            uint224(_seperateTSupply1) *
            NumericalConstants.SHIFT_51__224;
        _sSupplyVal +=
            uint224(_seperateTSupply2) *
            NumericalConstants.SHIFT_41__224;
        _sSupplyVal +=
            uint224(_seperateTSupply3) *
            NumericalConstants.SHIFT_31__224;
        _sSupplyVal +=
            uint224(_seperateISupply1) *
            NumericalConstants.SHIFT_21__224;
        _sSupplyVal +=
            uint224(_seperateISupply2) *
            NumericalConstants.SHIFT_11__224;
        _sSupplyVal += uint224(_seperateISupply3);

        return _sSupplyVal;
    }

    /**
     * @notice Decodes encoded input into its seven underlying raw values for the sSupplyVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within sSupplyVal.
     * @param _sSupplyVal Unsigned interger containing multiple compacted seperate sale supply definitions.
     */
    function _sSupplyValDecoder(
        uint224 _sSupplyVal
    )
        internal
        pure
        returns (
            uint8 _zeroVal,
            uint112 _seperateTSupply1,
            uint112 _seperateTSupply2,
            uint112 _seperateTSupply3,
            uint112 _seperateISupply1,
            uint112 _seperateISupply2,
            uint112 _seperateISupply3
        )
    {
        if (_sSupplyVal < NumericalConstants.MIN_SSUPPLY) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }

        // Extract _zeroVal
        _zeroVal = uint8((_sSupplyVal / NumericalConstants.SHIFT_61__224) % 10);
        if (_zeroVal > 1) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }

        _seperateTSupply1 = uint112(
            (_sSupplyVal / NumericalConstants.SHIFT_51__224) %
                NumericalConstants.SHIFT_11__224
        );
        _seperateTSupply2 = uint112(
            (_sSupplyVal / NumericalConstants.SHIFT_41__224) %
                NumericalConstants.SHIFT_11__224
        );
        _seperateTSupply3 = uint112(
            (_sSupplyVal / NumericalConstants.SHIFT_31__224) %
                NumericalConstants.SHIFT_11__224
        );
        _seperateISupply1 = uint112(
            (_sSupplyVal / NumericalConstants.SHIFT_21__224) %
                NumericalConstants.SHIFT_11__224
        );
        _seperateISupply2 = uint112(
            (_sSupplyVal / NumericalConstants.SHIFT_11__224) %
                NumericalConstants.SHIFT_11__224
        );
        _seperateISupply3 = uint112(
            _sSupplyVal % NumericalConstants.SHIFT_11__224
        );

        return (
            _zeroVal,
            _seperateTSupply1,
            _seperateTSupply2,
            _seperateTSupply3,
            _seperateISupply1,
            _seperateISupply2,
            _seperateISupply3
        );
    }

    /**
     * @notice Encodes four raw values related to the 39-digit cSupplyVal ContentToken property.
     * @dev Function called by script to correctly format stored sSupplyVal data.
     * @param _zeroVal Indicates presence of zero value.
     * @param _sWavReserve1 The first seperate sale WavReserve value defined for a CContentToken.
     * @param _sWavReserve2 The second seperate sale WavReserve value defined for a CContentToken.
     * @param _sWavReserve3 The third seperate sale WavReserve value defined for a CContentToken.
     * @param _sPreRelease1 The first seperate sale PreRelease allocation value defined for a CContentToken.
     * @param _sPreRelease2 The second seperate sale PreRelease allocation value defined for a CContentToken.
     * @param _sPreRelease3 The third seperate sale PreRelease allocation value defined for a CContentToken.
     */
    function _sReserveValEncoder(
        uint8 _zeroVal,
        uint80 _sWavReserve1,
        uint80 _sWavReserve2,
        uint80 _sWavReserve3,
        uint80 _sPreRelease1,
        uint80 _sPreRelease2,
        uint80 _sPreRelease3
    ) internal pure returns (uint160 _sReserveVal) {
        if (
            _zeroVal > 1 ||
            _sWavReserve1 >= NumericalConstants.SHIFT_7__160 ||
            _sWavReserve2 >= NumericalConstants.SHIFT_7__160 ||
            _sWavReserve3 >= NumericalConstants.SHIFT_7__160 ||
            _sPreRelease1 >= NumericalConstants.SHIFT_7__160 ||
            _sPreRelease2 >= NumericalConstants.SHIFT_7__160 ||
            _sPreRelease3 >= NumericalConstants.SHIFT_7__160
        ) {
            revert SupplyDBC__NumInputInvalid();
        }

        _sReserveVal = NumericalConstants.SHIFT_39__160;

        if (_zeroVal == 1) {
            _sReserveVal += NumericalConstants.SHIFT_37__160;
        }

        _sReserveVal += _sWavReserve1 * NumericalConstants.SHIFT_31__160;
        _sReserveVal += _sWavReserve2 * NumericalConstants.SHIFT_25__160;
        _sReserveVal += _sWavReserve3 * NumericalConstants.SHIFT_19__160;
        _sReserveVal += _sPreRelease1 * NumericalConstants.SHIFT_13__160;
        _sReserveVal += _sPreRelease2 * NumericalConstants.SHIFT_7__160;
        _sReserveVal += _sPreRelease3;

        return _sReserveVal;
    }

    /**
     * @notice Decodes encoded input into its seven underlying raw values for the sReserveVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within sReserveVal.
     * @param _sReserveVal Unsigned interger containing multiple compacted seperate sale reserve definitions.
     */
    function _sReserveValDecoder(
        uint160 _sReserveVal
    )
        internal
        pure
        returns (
            uint8 _zeroVal,
            uint80 _sWavReserve1,
            uint80 _sWavReserve2,
            uint80 _sWavReserve3,
            uint80 _sPreRelease1,
            uint80 _sPreRelease2,
            uint80 _sPreRelease3
        )
    {
        if (_sReserveVal < NumericalConstants.SHIFT_39__160) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }

        _zeroVal = uint8(
            (_sReserveVal / NumericalConstants.SHIFT_37__160) % 10
        );
        if (_zeroVal > 1) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }

        _sWavReserve1 = uint80(
            (_sReserveVal / NumericalConstants.SHIFT_31__160) %
                NumericalConstants.SHIFT_7__160
        );
        _sWavReserve2 = uint80(
            (_sReserveVal / NumericalConstants.SHIFT_25__160) %
                NumericalConstants.SHIFT_7__160
        );
        _sWavReserve3 = uint80(
            (_sReserveVal / NumericalConstants.SHIFT_19__160) %
                NumericalConstants.SHIFT_7__160
        );
        _sPreRelease1 = uint80(
            (_sReserveVal / NumericalConstants.SHIFT_13__160) %
                NumericalConstants.SHIFT_7__160
        );
        _sPreRelease2 = uint80(
            (_sReserveVal / NumericalConstants.SHIFT_7__160) %
                NumericalConstants.SHIFT_7__160
        );
        _sPreRelease3 = uint80(_sReserveVal % NumericalConstants.SHIFT_7__160);

        return (
            _zeroVal,
            _sWavReserve1,
            _sWavReserve2,
            _sWavReserve3,
            _sPreRelease1,
            _sPreRelease2,
            _sPreRelease3
        );
    }

    /**
     * @notice Encodes three raw values related to active supply locations of the service.
     * @dev Function called by script to efficiently store 31-digit remaining supply data.
     *      Function Selector: 0x209bb4af
     * @param _wavStoreSupplies First user-defined WavStore supply input.
     * @param _wavReserveSupplies Second user-defined WavReserve supply input.
     * @param _preReleaseSupplies Third user-defined PreRelease supply input.
     */
    function _remainingSupplyEncoder(
        uint112 _wavStoreSupplies,
        uint112 _wavReserveSupplies,
        uint112 _preReleaseSupplies
    ) internal pure returns (uint112 _remainingSupplyVal) {
        if (
            _wavStoreSupplies >= NumericalConstants.SHIFT_11 ||
            _wavReserveSupplies >= NumericalConstants.SHIFT_11 ||
            _preReleaseSupplies >= NumericalConstants.SHIFT_11
        ) {
            revert SupplyDBC__NumInputInvalid();
        }

        _remainingSupplyVal = NumericalConstants.SHIFT_31;

        _remainingSupplyVal += _wavStoreSupplies * NumericalConstants.SHIFT_21;
        _remainingSupplyVal +=
            _wavReserveSupplies *
            NumericalConstants.SHIFT_11;
        _remainingSupplyVal += _preReleaseSupplies;
        return _remainingSupplyVal;
    }

    /**
     * @notice Decodes encoded input into three underlying supply values.
     * @dev Function called by script to decode underlying data stored within cWavSupplies.
     *      Function Selector: 0x1014bf93
     * @param _remainingSupply Unsigned interger containing multiple compacted supply definitions.
     */
    function _remainingSupplyDecoder(
        uint112 _remainingSupply
    )
        internal
        pure
        returns (
            uint112 _wavStoreSupplies,
            uint112 _wavReserveSupplies,
            uint112 _preReleaseSupplies
        )
    {
        if (_remainingSupply < NumericalConstants.MIN_REMAINING_SUPPLY) {
            revert SupplyDBC__MinEncodedValueInvalid();
        }
        // Extract 'Y'
        _wavStoreSupplies =
            (_remainingSupply / NumericalConstants.SHIFT_21) %
            NumericalConstants.SHIFT_11;
        // Extract 'N'
        _wavReserveSupplies =
            (_remainingSupply / NumericalConstants.SHIFT_11) %
            NumericalConstants.SHIFT_11;
        // Extract 'J'
        _preReleaseSupplies = _remainingSupply % NumericalConstants.SHIFT_11;
        return (_wavStoreSupplies, _wavReserveSupplies, _preReleaseSupplies);
    }
}
