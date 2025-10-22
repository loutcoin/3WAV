// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @author Matthew Joseph Lout II
/// @title WavDBC
/// @notice Innovative technique (DBC) for efficient data storage and interpretation within smart contracts.
/// @dev Utilizes boolean algebra, bit manipulation, and stored data compaction to reduce gas costs.

// WIP: INCOMPLETE | NON-FUNCTIONAL (WIP)
import {WavToken} from "src/WavToken.sol";

contract WavDBC {
    error WavDBC__LengthValIssue();
    error WavDBC__BitValIssue();
    error WavDBC__NumInputInvalid();
    error WavDBC__MinEncodedValueInvalid();
    error WavDBC__SupplyAllocationError();
    error WavDBC__ReleaseInputIssue();
    error WavDBV__InputError404();


    uint96 internal constant SECOND_TO_HOUR_PRECISION = 3600;

    /// Used in cPriceUsdValEncoder
    uint32 internal constant LEADING_TEN__THIRTY_TWO_BIT = 1000000000;

    /// Used in cPriceUsdValDecoder
    uint32 internal constant MIN_ENCODED_CPRICE_USD_VAL = 1000000001;

    uint224 internal constant MIN_SSUPPLY = 100000000000100000000000000000000000000000000000000000000000000;

    uint224 internal constant SHIFT_63__224 = 10**62;

    uint224 internal constant SHIFT_61__224 = 10**60;

    uint224 internal constant SHIFT_51__224 = 10**50;

    uint224 internal constant SHIFT_41__224 = 10**40;

    uint224 internal constant SHIFT_31__224 = 10**30;

    uint224 internal constant SHIFT_21__224 = 10**20;

    uint224 internal constant SHIFT_11__224 = 10**10;

    /// Used in sPriceUsdValEncoder
    uint112 internal constant SHIFT_30 = 10**29;

    uint112 internal constant SHIFT_31 = 10**30;

    /// Used in sPriceUsdValEncoder
    uint112 internal constant SHIFT_28 = 10**27; 

    /// Used in sPriceUsdValEncoder
    uint112 internal constant SHIFT_19 = 10**18;

    uint80 internal constant SHIFT_19__80 = 10**18;

    uint96 internal constant SHIFT_19__96 = 10**18;

    uint96 internal constant SHIFT_20__96 = 10**19;

    /// Used in sPriceUsdValEncoder
    uint112 internal constant SHIFT_10 = 10**9;

    /// Used in sPriceUsdValDecoder
    uint112 internal constant MIN_ENCODED_SPRICE_USD_VAL = 100000000001000000000000000000;

    uint112 internal constant MIN_STOTAL = 100000000000100000000000000000000;

    uint112 internal constant MIN_REMAINING_SUPPLY = 1000000000100000000000000000000;

    // Used in cSupplyValEncoder
    uint112 internal constant SHIFT_33 = 10**32;

    uint112 internal constant SHIFT_11 = 10**10

    // Used in cSupplyValEncoder
    uint112 internal constant SHIFT_7 = 10**6;

    uint80 internal constant SHIFT_7__80 = 10**6;

    uint96 internal constant SHIFT_7__96 = 10**6;

    uint160 internal constant SHIFT_7__160 = 10**6;

    uint160 internal constant SHIFT_39__160 = 10**38;

    uint160 internal constant SHIFT_37__160 = 10**36;

    uint160 internal constant SHIFT_31__160 = 10**30;

    uint160 internal constant SHIFT_25__160 = 10**24;

    uint160 internal constant SHIFT_19__160 = 10**18;

    uint160 internal constant SHIFT_13__160 = 10**12;

    uint256 internal constant SHIFT_7__160 = 10**6;

    uint96 internal constant SHIFT_8__96 = 10**7;

    //Used in cSupplyValEncoder
    uint112 internal constant SHIFT_23 = 10**22;

    // Used in cSupplyValEncoder
    uint112 internal constant SHIFT_13 = 10**12;

    uint80 internal constant SHIFT_13__80 = 10**12;

    uint96 internal constant SHIFT_13__96 = 10**12;

    uint112 internal constant CPRE_SUPPLY_MAXIMUM = 400000;
    
    uint80 internal constant PRE_SUPPLY_MAX__80 = 400000;

    uint112 internal constant SHIFT_21 = 10**20;

    uint80 internal constant SHIFT_21__80 = 10**20;

    uint96 internal constant CRELEASE_6_MAX = 1000000

    uint96 internal constant SHIFT_1__96 = 10**1;



    WavToken WAVT;

    // START OF JULY 31 2025 NEW FUNCTIONS / REWRITES




    // ADD NATSPEC 
    // intended to format numbers like <1-xxxxxxx.xx>
    // need to add conditional to ensure input does not exceed 1999999999


    /**
     * @notice Standardizes the digit count of cPriceUsdVal.
     * @dev Function called by script to standardize digit count of cPriceUsdVal.
     *      Function Selector: 0xb9879684
     * @param _cPriceUsdInput Raw unsigned interger price definition.
    */
    function cPriceUsdValEncoder(uint32 _cPriceUsdInput) external pure returns(uint32 _cPriceUsdVal) {
        if(_cPriceUsdInput >= 1000000000) {
            revert WavDBC__NumInputInvalid();
        }
        LEADING_TEN__THIRTY_TWO_BIT + _cPriceUsdInput = _cPriceUsdVal;
        return _cPriceUsdVal;
    }

    // need to add conditional to ensure input does not exceed 1999999999
    /**
     * @notice Decodes cPriceUsdVal into its underlying value input.
     * @dev Function called by script to decode underlying data stored within cPriceUsdVal.
     *      Function Selector: 0xb7dc9ade
     * @param _cPriceUsdVal Unsigned interger containing Content Token price definition.
    */
    function cPriceUsdValDecoder(uint32 _cPriceUsdVal) external pure returns(uint32 _cPriceUsdRaw) {
        if(_cPriceUsdVal < MIN_ENCODED_CPRICE_USD_VAL) {
            revert WavDBC__MinEncodedValueInvalid();
        }
        _cPriceUsdRaw = _cPriceUsdVal - LEADING_TEN__THIRTY_TWO_BIT;
        return _cPriceUsdRaw;
    }


    // IS 30 DIGIT ENCODE KEY RN
    /** Technically doesn't currently check that accessible < standard < exclusive

     * @notice Encodes four raw values related to the sPriceUsdVal CContentToken property.
     * @dev Function called by script to correctly format stored sPriceUsdVal data.
     *      Function Selector: 0x6fb1d5e3
     * @param _zeroVal Indicates presence of zero value.
     * @param _standardPriceVal Standard numerical USD value assignable to Content Tokens seperately sold.
     * @param _accessiblePriceVal Optional lesser numerical USD value assignable to Content Tokens seperately sold.
     * @param _exclusivePriceVal Optional greater numerical USD value assignable to Content Tokens seperately sold.
     */
    function sPriceUsdValEncoder(
        uint8 _zeroVal,
        uint112 _standardPriceVal,
        uint112 _accessiblePriceVal,
        uint112 _exclusivePriceVal) external pure returns(uint112 _sPriceUsdVal) {
        // ensures inputs are less than 10 digits and _zeroVal is no greater than '1'
        if(_standardPriceVal >= SHIFT_10 ||
           _accessiblePriceVal >= SHIFT_10 ||
           _exclusivePriceVal >= SHIFT_10 ||
           _zeroVal > 1 ||
           _standardPriceVal == 0) {
            revert WavDBC__NumInputInvalid();
         }
         // (if no _zeroVal '101...') else '100...')
         if(_zeroVal == 1) {
            _sPriceUsdVal = SHIFT_30 + SHIFT_28;
         } else {
            _sPriceUsdVal = SHIFT_30;
         }
         _sPriceUsdVal += _standardPriceVal * SHIFT_19;
         _sPriceUsdVal += _accessiblePriceVal * SHIFT_10;
         _sPriceUsdVal += _exclusivePriceVal;
         return _sPriceUsdVal;
    }


    /**
     * @notice Decodes encoded input into its underlying four raw values for the sPriceUsdVal CContentToken property.
     * @dev Function called by script to decode underlying data stored within sPriceUsdVal.
     *      Function Selector: 0x814a4248
     * @param _sPriceUsdVal Unsigned interger containing multiple compacted seperate sale definitions.
     */
    function sPriceUsdValDecoder(
        uint112 _sPriceUsdVal) 
        external 
        pure 
        returns(
        uint8 _zeroVal,
        uint112 _standardPriceVal,
        uint112 _accessiblePriceVal,
        uint112 _exclusivePriceVal) {
        if(_sPriceUsdVal < MIN_ENCODED_SPRICE_USD_VAL) {
            revert WavDBC__MinEncodedValueInvalid();
        }
        // Extract 'X'
        _zeroVal = uint8((_sPriceUsdVal / SHIFT_28) % 10);
        if(_zeroVal > 1) {
            revert WavDBC__MinEncodedValueInvalid();
        }
        // Extract 'Y'
        _standardPriceVal = (_sPriceUsdVal / SHIFT_19) % SHIFT_10;
        // Extract 'N'
        _accessiblePriceVal = (_sPriceUsdVal / SHIFT_10) % SHIFT_10;
        // Extract 'J'
        _exclusivePriceVal = _sPriceUsdVal % SHIFT_10;
        return(_zeroVal, _standardPriceVal, _accessiblePriceVal, _exclusivePriceVal);
        }



        /**
        * @notice Determines numerical value correlated to bit state of a hashId.
        * @dev Function called during Content Token price validation.
        *      Function Selector: 0x48992985
        * @param _bitState Attributed symbolic binary state associated with user-defined numerical value.
        * @param _sPriceUsdVal Unsigned interger containing multiple numerical value states.
        * @param _hashId Unique identifier of the Content Token.
        */
        function sPriceUsdValState(uint8 _bitState, uint112 _sPriceUsdVal, bytes32 _hashId) internal view returns(uint112) {
            if(_bitState == 1) {
                (, , uint112 _accessiblePriceVal,) = sPriceUsdValDecoder(_sPriceUsdVal);
                return _accessiblePriceVal;
            }
            if(_bitState == 2) {
                (, uint112 _standardPriceVal, ,) = sPriceUsdValDecoder(_sPriceUsdVal);
                return _standardPriceVal;
            }
            if(_bitState == 3) {
                (, , , uint112 _exclusivePriceVal) = sPriceUsdValDecoder(_sPriceUsdVal);
                return _exclusivePriceVal;
            } 
        } // either return(0) or possibly revert as you cannot buy something that isn't for sale





        // no need for zeroVal
        // wavR + initialSupply CANNOT be greater than total supply
    /**
     * @notice Encodes four raw values related to the cSupplyVal CContentToken property.
     * @dev Function called by script to correctly format stored cSupplyVal data.
     *      Function Selector: 0x35a93e5a
     * @param _totalSupply Maximum supply value defined for a CContentToken.
     * @param _initialSupply Initial supply value defined for a CContentToken.
     * @param _wavReserve Optional Content Token allocation reserve value.
     * @param _preSupply Optional Content Token pre-sale reserve value.
     */
    function cSupplyValEncoder(
        uint112 _totalSupply,
        uint112 _initialSupply,
        uint112 _wavReserve,
        uint112 _preSupply) external pure returns(uint112 _cSupplyVal) {
         if( 
            // _totalSupply must be at least 1 and no more than 10 digits
            _totalSupply < 1 || 
            _totalSupply >= SHIFT_11 ||
            // _initialSupply can be no more than 10 digits or exceed _totalSupply
            _initialSupply >= SHIFT_11 || 
            _initialSupply > _totalSupply ||
            // _wavReserve and _preSupply cannot be exceed 6 numerical digits
            _wavReserve >= SHIFT_7 || 
            _preSupply >= SHIFT_7 || // possibly redundant 
            // _preSupply capped at 40% of _totalSupply, _wavReserve + _preSupply <= 100%
            _preSupply > CPRE_SUPPLY_MAXIMUM || 
            (_wavReserve + _preSupply) > SHIFT_7
            // _totalSupply allocations should not exceed 100% the value of _totalSupply   
            ) {
                revert WavDBC__SupplyAllocationError();
            } 

            _cSupplyVal = SHIFT_33;

            _cSupplyVal += _totalSupply * SHIFT_23;
            _cSupplyVal += _initialSupply * SHIFT_13;
            _cSupplyVal += _wavReserve * SHIFT_7;
            _cSupplyVal += _preSupply;
            return _cSupplyVal;

    }


    function cSupplyValDecoder(
        uint112 _cSupplyVal
    ) external pure returns(
        uint112 _totalSupply,
        uint112 _initialSupply,
        uint112 _wavReserve,
        uint112 _preSupply
    ) {
        if(_cSupplyVal < SHIFT_33) {
            revert WavDBC__MinEncodedValueInvalid();
        }

        // Extract fields using the same shifts as the encoder
        _totalSupply = uint112((_cSupplyVal / SHIFT_23) % SHIFT_11);
        _initialSupply = uint112((_cSupplyVal / SHIFT_13) % SHIFT_11);
        _wavReserve = uint112((_cSupplyVal / SHIFT_7) % SHIFT_7);
        _preSupply = uint112(_cSupplyVal % SHIFT_7);

        return(_totalSupply, _initialSupply, _wavReserve, _preSupply);
        
    
    }


        // UNFINISHED
        // should be called after conditional in cSupplyValEncoder
        // should ensure preSupply <= 40% _totalSupply

    /**
    * @notice Further validates inputs for cSupplyValEncoder.
    * @dev Function called during execution of cSupplyValEncoder to validate validity of input values.
    *      Function Selector: 0x9d730959
    * @param _totalSupply Total supply input for cSupplyVal property.
    * @param _initialSupply Initial supply input for cSupplyVal property.
    * @param _wavReserve WavReserve allocation input for cSupplyVal property.
    * @param _preSupply PreSupply allocation input for cSupplyVal property.
    */
  /*  function _cSupplyAllocationVerification(
        uint112 _totalSupply,
        uint112 _initialSupply,
        uint112 _wavReserve,
        uint112 _preSupply) 
        internal pure {
                if( 
                    // _totalSupply must be at least 1 and no more than 10 digits
                _totalSupply < 1 || 
                _totalSupply >= SHIFT_11 ||
                    
                    // _initialSupply can be no more than 10 digits or exceed _totalSupply
                _initialSupply >= SHIFT_11 || 
                _initialSupply > _totalSupply ||

                    // _wavReserve and _preSupply cannot be exceed 6 numerical digits
                _wavReserve >= SHIFT_7 || 
                _preSupply >= SHIFT_7 || // possibly redundant 

                    // _preSupply capped at 40% of _totalSupply, _wavReserve + _preSupply <= 100%
                _preSupply > CPRE_SUPPLY_MAXIMUM || 
                (_wavReserve + _preSupply) > SHIFT_7 ||

                    // _totalSupply allocations should not exceed 100% the value of _totalSupply   
                ) {
                    revert WavDBC__SupplyAllocationError();
                } 
        } */

   
    /**
     * @notice Encodes four raw values related to the sTotalSupply CContentToken property.
     * @dev Function called by script to correctly format stored sTotalSupply data.
     *      Function Selector: 0x4b6878b0
     * @param _zeroVal Indicates presence of zero value.
     * @param _seperateTSupply1 First user-defined total supply input for seperately sold Content Tokens.
     * @param _seperateTSupply2 Second user-defined total supply input for seperately sold Content Tokens.
     * @param _seperateTSupply3 Third user-defined total supply input for seperately sold Content Tokens.
     */
        function sTotalSupplyEncoder(
            uint8 _zeroVal,
            uint112 _seperateTSupply1, 
            uint112 _seperateTSupply2, 
            uint112 _seperateTSupply3) 
            external 
            pure 
            returns(uint112 _sTotalSupply) {
            if(
                _zeroVal > 1 ||
                _seperateTSupply1 >= SHIFT_11 ||
                _seperateTSupply2 >= SHIFT_11 ||
                _seperateTSupply3 >= SHIFT_11 ||
                ) {
                    revert WavDBC__NumInputInvalid();
                }
                
            if(_zeroVal == 1) {
                _sTotalSupply = SHIFT_33 + SHIFT_31;
            } else {
                _sTotalSupply = SHIFT_33;
            }   
            _sTotalSupply += _seperateTSupply1 * SHIFT_21;
            _sTotalSupply += _seperateTSupply2 * SHIFT_11;
            _sTotalSupply += _seperateTSupply3;
            return _sTotalSupply;

        }



        /**
        * @notice Decodes encoded input into its underlying four raw values for the sTotalSupply CContentToken property.
        * @dev Function called by script to decode underlying data stored within sTotalSupply.
        *      Function Selector: 0x03c7c796
        * @param _sTotalSupply Unsigned interger containing multiple compacted supply definitions.
        */
        function sTotalSupplyDecoder(uint112 _sTotalSupply) external pure returns(
            uint8 _zeroVal, 
            uint112 _seperateTSupply1,
            uint112 _seperateTSupply2,
            uint112 _seperateTSupply3) {
            if(_sTotalSupply < MIN_STOTAL) {
                revert WavDBC__MinEncodedValueInvalid();
            }
             // Extract 'X'
            _zeroVal = uint8((_sTotalSupply / SHIFT_31) % 10);
            if(_zeroVal > 1) {
                revert WavDBC__MinEncodedValueInvalid();
            }
            // Extract 'Y'
            _seperateTSupply1 = (_sTotalSupply / SHIFT_21) % SHIFT_11;
            // Extract 'N'
            _seperateTSupply2 = (_sTotalSupply / SHIFT_11) % SHIFT_11;
            // Extract 'J'
            _seperateTSupply3 = _sTotalSupply % SHIFT_11;
            return(_zeroVal, _seperateTSupply1, _seperateTSupply2, _seperateTSupply3);
        }





        // POSSIBLY literally identical to sTotalSupply Encode / Decode
        // Current is LITERAL implementation


        /**
        * @notice Encodes four raw values related to the sInitialSupply CContentToken property.
        * @dev Function called by script to correctly format stored sInitialSupply data.
        *      Function Selector: 0xc11c0db5
        * @param _zeroVal Indicates presence of zero value.
        * @param _seperateISupply1 First user-defined initial supply input for seperately sold Content Tokens.
        * @param _seperateISupply2 Second user-defined initial supply input for seperately sold Content Tokens.
        * @param _seperateISupply3 Third user-defined initial supply input for seperately sold Content Tokens.
        */
        function sInitialSupplyEncoder(
            uint8 _zeroVal,
            uint112 _seperateISupply1,
            uint112 _seperateISupply2,
            uint112 _seperateISupply3
        ) external pure returns(uint112 _sInitialSupply) {
            if(
                    _zeroVal > 1 ||
                    _seperateISupply1 >= SHIFT_11 ||
                    _seperateISupply2 >= SHIFT_11 ||
                    _seperateISupply3 >= SHIFT_11
                    ) {
                        revert WavDBC__NumInputInvalid();
                    }
                
                if(_zeroVal == 1) {
                   _sInitialSupply = SHIFT_33 + SHIFT_31;
                } else {
                    _sInitialSupply = SHIFT_33;
            }   
                _sInitialSupply += _seperateISupply1 * SHIFT_21;
                _sInitialSupply += _seperateISupply2 * SHIFT_11;
                _sInitialSupply += _seperateISupply3;
                return _sInitialSupply;
        }


        /**
        * @notice Decodes encoded input into its underlying four raw values for the sInitialSupply CContentToken property.
        * @dev Function called by script to decode underlying data stored within sInitialSupply.
        *      Function Selector: 0x1014bf93
        * @param _sInitialSupply Unsigned interger containing multiple compacted supply definitions.
        */
        function sInitialSupplyDecoder(
            uint112 _sInitialSupply
        ) external pure returns(
            uint8 _zeroVal, 
            uint112 _seperateISupply1,
            uint112 _seperateISupply2,
            uint112 _seperateISupply3
        ) {
            if(_sInitialSupply < MIN_STOTAL) {
                revert WavDBC__MinEncodedValueInvalid();
            }
             // Extract 'X'
            _zeroVal = uint8((_sInitialSupply / SHIFT_31) % 10);
            if(_zeroVal > 1) {
                revert WavDBC__MinEncodedValueInvalid();
            }
            // Extract 'Y'
            _seperateISupply1 = (_sInitialSupply / SHIFT_21) % SHIFT_11;
            // Extract 'N'
            _seperateISupply2 = (_sInitialSupply / SHIFT_11) % SHIFT_11;
            // Extract 'J'
            _seperateISupply3 = _sInitialSupply % SHIFT_11;
            return(_zeroVal, _seperateISupply1, _seperateISupply2, _seperateISupply3);
            
        }

        function sSupplyValEncoder(
            uint8 _zeroVal,
            uint112 _seperateTSupply1,
            uint112 _seperateTSupply2,
            uint112 _seperateTSupply3,
            uint112 _seperateISupply1,
            uint112 _seperateISupply2,
            uint112 _seperateISupply3
        ) external pure returns(uint224 _sSupplyVal) {
            if(
                _zeroVal > 1 ||
                _seperateTSupply1 >= SHIFT_11 ||
                _seperateTSupply2 >= SHIFT_11 ||
                _seperateTSupply3 >= SHIFT_11 ||
                _seperateTSupply1 >= SHIFT_11 ||
                _seperateTSupply2 >= SHIFT_11 ||
                _seperateTSupply3 >= SHIFT_11
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _sSupplyVal = SHIFT_63__224;

            if(_zeroVal == 1) {
                _sSupplyVal += SHIFT_61__224;
            }

            _sSupplyVal += uint224(_seperateTSupply1) * SHIFT_51__224;
            _sSupplyVal += uint224(_seperateTSupply2) * SHIFT_41__224;
            _sSupplyVal += uint224(_seperateTSupply3) * SHIFT_31__224;
            _sSupplyVal += uint224(_seperateISupply1) * SHIFT_21__224;
            _sSupplyVal += uint224(_seperateISupply2) * SHIFT_11__224;
            _sSupplyVal += uint224(_seperateISupply3);

            return _sSupplyVal
        }


        function sSupplyValDecoder(
            uint224 _sSupplyVal
        ) external pure returns(
            uint8 _zeroVal,
            uint112 _seperateTSupply1,
            uint112 _seperateTSupply2,
            uint112 _seperateTSupply3,
            uint112 _seperateISupply1,
            uint112 _seperateISupply2,
            uint112 _seperateISupply3
        ) {
            if(_sSupplyVal < MIN_SSUPPLY) {
                revert WavDBC__MinEncodedCalueInvalid();
            }

            // Extract _zeroVal
            _zeroVal = uint8((_sSupplyVal / SHIFT_61__224) % 10);
            if(_zeroVal > 1) {
                revert WavDBC__MinEncodedValueInvalid();
            }

            _seperateTSupply1 = uint112((_sSupplyVal / SHIFT_51__224) % SHIFT_11__224);
            _seperateTSupply2 = uint112((_sSupplyVal / SHIFT_41__224) % SHIFT_11__224);
            _seperateTSupply3 = uint112((_sSupplyVal / SHIFT_31__224) % SHIFT_11__224);
            _seperateISupply1 = uint112((_sSupplyVal / SHIFT_21__224) % SHIFT_11__224);
            _seperateISupply2 = uint112((_sSupplyVal / SHIFT_11__224) % SHIFT_11__224);
            _seperateISupply3 = uint112(_sSupplyVal % SHIFT_11__224);

            return(_zeroVal, _seperateTSupply1, _seperateTSupply2, _seperateTSupply3, _seperateISupply1, _seperateISupply2, _seperateISupply3);
        }

        /**
        * @notice Encodes four raw values related to the sWavR CContentToken property.
        * @dev Function called by script to correctly format stored sWavR data.
        *      Function Selector: 0x4ee020bb
        * @param _zeroVal Indicates presence of zero value.
        * @param _seperateWavR1 First user-defined WavReserve input for seperately sold Content Tokens.
        * @param _seperateWavR2 Second user-defined WavReserve input for seperately sold Content Tokens.
        * @param _seperateWavR3 Third user-defined WavReserve input for seperately sold Content Tokens.
        */
        function sWavREncoder(
            uint8 _zeroVal,
            uint80 _seperateWavR1,
            uint80 _seperateWavR2,
            uint80 _seperateWavR3) external pure returns(uint80 _sWavR) {
                 if(
                    _zeroVal > 1 ||
                    _seperateWavR1 >= SHIFT_7__80 ||
                    _seperateWavR2 >= SHIFT_7__80 ||
                    _seperateWavR3 >= SHIFT_7__80 ||) {
                        revert WavDBC__NumInputInvalid();
                    }

                if(_zeroVal == 1) {
                    _sWavR = SHIFT_21__80 + SHIFT_19__80;
                    }    else {
                        _sWavR = SHIFT_21__80;
                    }   
                _sWavR += _seperateWavR1 * SHIFT_13__80;
                _sWavR += _seperateWavR2 * SHIFT_7__80;
                _sWavR += _seperateWavR3;
                return _sWavR;
            
            }


        /**
        * @notice Decodes encoded input into its underlying four raw values for the sWavR CContentToken property.
        * @dev Function called by script to decode underlying data stored within sWavR.
        *      Function Selector: 0xe5b184d2
        * @param _sWavR Unsigned interger containing multiple reserve allocation values.
        */
            function sWavRDecoder(
                uint80 _sWavR
            ) external pure returns(
                uint8 _zeroVal,
                uint80 _seperateWavR1,
                uint80 _seperateWavR2,
                uint80 _seperateWavR3) {
                if(_sWavR < SHIFT_21__80) {
                    revert WavDBC__NumInputInvalid();
                }
                // Extract 'X'
                _zeroVal = uint8((_sWavR / SHIFT_19__80) % 10);
                if(_zeroVal > 1) {
                    revert WavDBC__MinEncodedValueInvalid();
                }
                // Extract 'Y'
                _seperateWavR1 = (_sWavR / SHIFT_13__80) % SHIFT_7__80;
                // Extract 'N'
                _seperateWavR2 = (_sWavR / SHIFT_7__80) % SHIFT_7__80;
                // Extract 'J'
                _seperateWavR3 = _sWavR % SHIFT_7__80;
                return(_zeroVal, _seperateWavR1, _seperateWavR2, _seperateWavR3);
                }



        /**
        * @notice Encodes four raw values related to the sPreSaleR CContentToken property.
        * @dev Function called by script to correctly format stored sPreSaleR data.
        *      Function Selector: 0x74cb352c
        * @param _zeroVal Indicates presence of zero value.
        * @param _sPreSupply1 First user-defined preSupply input for seperately sold Content Tokens.
        * @param _sPreSupply2 Second user-defined preSupply input for seperately sold Content Tokens.
        * @param _sPreSupply3 Third user-defined preSupply input for seperately sold Content Tokens.
        */
            function sPreSaleREncoder(
                uint8 _zeroVal,
                uint80 _sPreSupply1,
                uint80 _sPreSupply2,
                uint80 _sPreSupply3
            ) external pure returns(uint80 _sPreSaleR) {
                if(
                    _zeroVal > 1 ||
                    _sPreSupply1 > PRE_SUPPLY_MAX__80 ||
                    _sPreSupply2 > PRE_SUPPLY_MAX__80 ||
                    _sPreSupply3 > PRE_SUPPLY_MAX__80 ||
                    ) {
                        revert WavDBC__NumInputInvalid();
                    }

                if(_zeroVal == 1) {
                    _sPreSaleR = SHIFT_21__80 + SHIFT_19__80;
                    }    else {
                        _sPreSaleR = SHIFT_21__80;
                    }   
                _sPreSaleR += _sPreSupply1 * SHIFT_13__80;
                _sPreSaleR += _sPreSupply2 * SHIFT_7__80;
                _sPreSaleR += _sPreSupply3;
                return _sPreSaleR;
            }

            
        /**
        * @notice Decodes encoded input into its underlying four raw values for the sPreSaleR CContentToken property.
        * @dev Function called by script to decode underlying data stored within sPreSaleR.
        *      Function Selector: 0x771469ee
        * @param _sPreSaleR Unsigned interger containing preSale allocation values.
        */
        function sPreSaleRDecoder(
                uint80 _sPreSaleR
            ) external pure returns(
                _zeroVal,
                _sPreSupply1,
                _sPreSupply2,
                _sPreSupply3) {
                if(_sPreSaleR < SHIFT_21__80) {
                    revert WavDBC__NumInputInvalid();
                }
                // Extract 'X'
                _zeroVal = uint8((_sPreSaleR / SHIFT_19__80) % 10);
                if(_zeroVal > 1) {
                    revert WavDBC__MinEncodedValueInvalid();
                }
                // Extract 'Y'
                _sPreSupply1 = (_spreSaleR / SHIFT_13__80) % SHIFT_7__80;
                // Extract 'N'
                _sPreSupply2 = (_PreSaleR / SHIFT_7__80) % SHIFT_7__80;
                // Extract 'J'
                _preSupply3 = _sPreSaleR % SHIFT_7__80;
                // Return Result
                return(_zeroVal, _sPreSupply1, _sPreSupply2, _sPreSupply3);
            }




            function sReserveValEncoder(
                uint8 _zeroVal,
                uint80 _sWavReserve1,
                uint80 _sWavReserve2,
                uint80 _sWavReserve3,
                uint80 _sPreRelease1,
                uint80 _sPreRelease2,
                uint80 _sPreRelease3
            ) external pure returns(uint160 _sReserveVal) {
                if(
                    _zeroVal > 1 ||
                    _sWavReserve1 >= SHIFT_7__160 ||
                    _sWavReserve2 >= SHIFT_7__160 ||
                    _sWavReserve3 >= SHIFT_7__160 ||
                    _sPreRelease1 >= SHIFT_7__160 ||
                    _sPreRelease2 >= SHIFT_7__160 ||
                    _sPreRelease3 >= SHIFT_7__160 
                ) {
                    revert WavDBC__NumInputInvalid();
                }

                _sReserveVal = SHIFT_39__160;

                if(_zeroVal == 1) {
                    _sReserveVal += SHIFT_37__160;
                }

                _sReserveVal += _sWavReserve1 * SHIFT_31__160;
                _sReserveVal += _sWavReserve2 * SHIFT_25__160;
                _sReserveVal += _sWavReserve3 * SHIFT_19__160;
                _sReserveVal += _sPreRelease1 * SHIFT_13__160;
                _sReserveVal += _sPreRelease2 * SHIFT_6__160;
                _sReserveVal += _sPreRelease3

                return _sReserveVal;
            }

            function sReserveValDecoder(
                uint160 _sReserveVal
            ) external pure returns(
                uint8 _zeroVal,
                uint80 _sWavReserve1,
                uint80 _sWavReserve2,
                uint80 _sWavReserve3,
                uint80 _sPreRelease1,
                uint80 _sPreRelease2,
                uint80 _sPreRelease3
            ) {
                if(_sReserveVal < SHIFT_39__160) {
                    revert WavDBC__MinEncodedValueInvalid();
                }

                _zeroVal = uint8((_sReserveVal / SHIFT_37__160) % 10);
                if(_zeroVal > 1) {
                    revert WavDBC__MinEncodedValueInvalid();
                }
                
                _sWavReserve1 = uint80((_sReserveVal / SHIFT_31__160) % SHIFT_7__160);
                _sWavReserve2 = uint80((_sReserveVal / SHIFT_25__160) % SHIFT_7__160);
                _sWavReserve3 = uint80((_sReserveVal / SHIFT_19__160) % SHIFT_7__160);
                _sPreRelease1 = uint80((_sReserveVal / SHIFT_13__160) % SHIFT_7__160);
                _sPreRelease2 = uint80((_sReserveVal / SHIFT_7__160) % SHIFT_7__160);
                _sPreRelease3 = uint80(_sReserveVal % SHIFT_7__160);

                return(_zeroVal, _sWavReserve1, _sWavReserve2, _sWavReserve3, _sPreRelease1, _sPreRelease2, _sPreRelease3);
            }




        /**
        * @notice Encodes three raw values related to active supply locations of the service.
        * @dev Function called by script to efficiently store remaining supply data.
        *      Function Selector: 0x209bb4af
        * @param _wavStoreSupplies First user-defined WavStore supply input.
        * @param _wavReserveSupplies Second user-defined WavReserve supply input.
        * @param _preReleaseSupplies Third user-defined PreRelease supply input.
        */
        function remainingSupplyEncoder(
            uint112 _wavStoreSupplies,
            uint112 _wavReserveSupplies,
            uint112 _preReleaseSupplies
        ) external pure returns(uint112 _remainingSupplyVal) {
            if(
                    _wavStoreSupplies >= SHIFT_11 ||
                    _wavReserveSupplies >= SHIFT_11 ||
                    _preReleaseSupplies >= SHIFT_11
                    ) {
                        revert WavDBC__NumInputInvalid();
                    }
                    
                    _remainingSupplyVal = SHIFT_31;
              
                _remainingSupplyVal += _wavStoreSupplies * SHIFT_21;
                _remainingSupplyVal += _wavReserveSupplies * SHIFT_11;
                _remainingSupplyVal += _preReleaseSupplies;
                return _remainingSupplyVal;
        }

        /**
        * @notice Decodes encoded input into three underlying supply values.
        * @dev Function called by script to decode underlying data stored within cWavSupplies.
        *      Function Selector: 0x1014bf93
        * @param _remainingSupply Unsigned interger containing multiple compacted supply definitions.
        */
        function remainingSupplyDecoder(
            uint112 _remainingSupply
        ) external pure returns(
            uint112 _wavStoreSupplies,
            uint112 _wavReserveSupplies,
            uint112 _preReleaseSupplies
        ) {
            if(_remainingSupply < MIN_REMAINING_SUPPLY) {
                revert WavDBC__MinEncodedValueInvalid();
            }
            // Extract 'Y'
            _wavStoreSupplies = (_sInitialSupply / SHIFT_21) % SHIFT_11;
            // Extract 'N'
            _wavReserveSupplies = (_sInitialSupply / SHIFT_11) % SHIFT_11;
            // Extract 'J'
            _preReleaseSupplies = _sInitialSupply % SHIFT_11;
            return(_wavStoreSupplies, _wavReserveSupplies, _preReleaseSupplies);
        }


        
        /**
        * @notice Encodes four raw values related to the cReleaseVal Content Token property.
        * @dev Function called by script to correctly format stored cReleaseVal data.
        *      Function Selector: 0x6e8c4a2d
        * @param _startRelease The intended official publication date of a Content Token.
        * @param _endRelease An optional disable date for official sale of a Content Token.
        * @param _preRelease An optional timestamp for an enabled preSale period to occur.
        * @param _pausedAt Variable sale-state property.
        */
        function cReleaseValEncoder6(
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt
        ) external pure returns(uint96 _releaseVal) {
            uint96 _hourStamp = hourStamp();
            if(
                _startRelease < _hourStamp ||
                _endRelease < _hourStamp ||
                _preRelease < _hourStamp ||
                _pausedAt > 1 ||
                _startRelease >= CRELEASE_6_MAX ||
                _endRelease >= CRELEASE_6_MAX ||
                _preRelease >= CRELEASE_6_MAX
            ) {
                revert WavDBC__ReleaseInputIssue();
            }
            _releaseVal += _startRelease * SHIFT_13__96;
            _releaseVal += _endRelease * SHIFT_7__96;
            _releaseVal += _preRelease * SHIFT_1__96;
            _releaseVal += _pausedAt;
            return _releaseVal;

        }

        /**
        * @notice Encodes a batch of four input values related to multiple cReleaseVal properties.
        * @param _startReleaseBatch Array of official Content Token publication dates.
        * @param _endReleaseBatch Array of Content Token optional termination of sale timestamps.
        * @param _preReleaseBatch Array of Content Token optional preSale period timestamps.
        * @param _pausedAtBatch Array of variable sale-state properties.
        *
         */
        function cReleaseValEncoderBatch6(
            uint96[] calldata _startReleaseBatch,
            uint96[] calldata _endReleaseBatch,
            uint96[] calldata _preReleaseBatch,
            uint8[] calldata _pausedAtBatch
        ) external pure returns(uint96[] memory _releaseValBatch) {
            uint96 _releaseLength = _startReleaseBatch.length;
            
            if(
                _releaseLength != _endReleaseBatch.length ||
                _releaseLength != _preReleaseBatch.length ||
                _releaseLength != _pausedAtBatch.length) {
                revert WavDBC__LengthValIssue();
            }

            if(_releaseLength == 0) {
                return new uint96[](0);
            }

            uint96 _hourStamp = hourStamp();
            
            for(uint96 i = 0; i < _releaseLength;) {
                uint96 _str = _startReleaseBatch[i];
                uint96 _end = _endReleaseBatch[i];
                uint96 _pre = _preReleaseBatch[i];
                uint8 _paused = _pausedAtBatch[i];

                if(
                    _str >= SHIFT_7__96 ||
                    _end >= SHIFT_7__96 ||
                    _pre >= SHIFT_7__96 ||
                    _paused > 1) {
                        revert WavDBC__ReleaseInputIssue();
                    }
                // TEST IF PARENTHESIS ARE NEEDED FOR FUNCTIONAL SYNTAX
                _releaseValBatch[i] =
                _str * SHIFT_13__96 +
                _end * SHIFT_7__96 +
                _pre * SHIFT_1__96 +
                uint96(_paused);

                unchecked { ++i; }
            }
                
                
                
                
                // this is where a lot of the report corrections take place from here
                
              
              
              
              /*  if(
                    _startReleaseBatch[i] < _hourStamp ||
                    _endReleaseBatch[i] < _hourStamp ||
                    _preReleaseBatch[i] < _hourStamp ||
                    _pausedAtBatch[i] > 1 ||
                    _startReleaseBatch[i] >= CRELEASE_6_MAX ||
                    _endReleaseBatch[i] >= CRELEASE_6_MAX ||
                    _preReleaseBatch[i] >= CRELEASE_6_MAX) {
                    revert WavDBC__ReleaseInputIssue();
                }
                _releaseValBatch[i] += _startReleaseBatch[i] * SHIFT_13__96;
                _releaseValBatch[i] += _endReleaseBatch[i] * SHIFT_7__96;
                _releaseValBatch[i] += _preReleaseBatch[i] * SHIFT_1__96;
                _releaseValBatch[i] += _pausedAtBatch[i];
            
          */   return _releaseValBatch;
        }


        /**
        * @notice Decodes underlying values within the releaseVal CContentToken property.
        * @dev Function called by script to decode underlying data stored within releaseVal.
        *      Function Selector: 0x70f143f2
        * @param _releaseVal Unsigned interger containing timestamp publication data.
        */
        function cReleaseValDecoder6(uint96 _releaseVal) external pure returns(
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt) {
                if(
                    _releaseVal <= SHIFT_19__96 ||
                    _releaseVal >= SHIFT_20__96) {
                        revert WavDBC__NumInputInvalid();
                    }
                _startRelease = _releaseVal / SHIFT_13__96;
                _endRelease = (_releaseVal / SHIFT_8__96) % SHIFT_7__96;
                _preRelease = (_releaseVal / SHIFT_1__96) % SHIFT_7__96;
                _pausedAt = uint8(_releaseVal % SHIFT_1__96);

                return(_startRelease, _endRelease, _preRelease, _pausedAt);
            }



        /**
        * @notice Decodes underlying values within releaseValBatch.
        * @dev Function called by script to decode underlying data stored within releaseValBatch.
        *      Function Selector: 0x70f143f2
        * @param _releaseValBatch Batch of unsigned intergers containing timestamp publication data.
        */
            function cReleaseValDecoderBatch6(uint96[] calldata _releaseValBatch) external pure returns(
                uint96[] memory _startReleaseBatch,
                uint96[] memory _endReleaseBatch,
                uint96[] memory _preReleaseBatch,
                uint8[] memory _pausedAtBatch
            ) {
                uint96 _releaseLength = _releaseValBatch.length;

                if(_releaseLength < 2) {
                    revert WavDBC__LengthValIssue(); 
                }

                _startReleaseBatch = new uint96[](_releaseLength);
                _endReleaseBatch = new uint96[](_releaseLength);
                _preReleaseBatch = new uint96[](_releaseLength);
                _pausedAtBatch = new uint8[](_releaseLength);

                for(uint256 i = 0; i < _releaseLength;) {
                   uint96 _packed = _releaseValBatch[i];

                   // mirror your single-instance validation
                   if(
                    _packed <= SHIFT_19__96 ||
                    _packed >= SHIFT_20__96) {
                        revert WavDBC__MinEncodedValueInvalid();
                    }
                    // inline decode exactly as in cReleaseValDecoder6
                    _startReleaseBatch[i] = _packed / SHIFT_13__96;
                    _endReleaseBatch[i] = (_packed / SHIFT_8__96) % SHIFT_7__96;
                }   
    

            }

        /**
        * @notice Decodes underlying data within encoded royaltyVal value.
        * @dev Function called by script to decode underlying data stored within royaltyVal.
        *      Function Selector: 0xf514db49
        * @param _zeroVal Indicates presence of zero value.
        * @param _royalty1 First user-defined collaborator royalty share value.
        * @param _royalty2 Second user-defined collaborator royalty share value.
        * @param _royalty3 Third user-defined collaborator royalty share value.
        * @param _royalty4 Fourth user-defined collaborator royalty share value.
        * @param _royalty5 Fifth user-defined collaborator royalty share value.
        * @param _royalty6 Sixth user-defined collaborator royalty share value.
        */
        function royaltyValEncoder(
            uint8 _zeroVal,
            uint32 _royalty1,
            uint32 _royalty2,
            uint32 _royalty3,
            uint32 _royalty4,
            uint32 _royalty5,
            uint32 _royalty6
        ) external pure returns(uint128 _royaltyVal) {
            if(
                _zeroVal > 1 ||
                _royalty1 >= SHIFT_6__32 ||
                _royalty2 >= SHIFT_6__32 ||
                _royalty3 >= SHIFT_6__32 ||
                _royalty4 >= SHIFT_6__32 ||
                _royalty5 >= SHIFT_6__32 ||
                _royalty6 >= SHIFT_6__32
            ) {
                revert WavDBC__NumInputInvalid();
            }
            // leading '1' at digit of greatest significance
            _royaltyVal = uint128(10**38);

            if(_zeroVal == 1) {
                _royaltyVal += uint128(10**36);
            }
            // Position the six 6-digit royalty inputs
            _royaltyVal += uint128(uint256(_royalty1) * 10**31);
            _royaltyVal += uint128(uint256(_royalty2) * 10**25);
            _royaltyVal += uint128(uint256(_royalty3) * 10**19);
            _royaltyVal += uint128(uint256(_royalty4) * 10**13);
            _royaltyVal += uint128(uint256(_royalty5) * 10**7);
            _royaltyVal += uint128(_royalty6);

            return _royaltyVal;
        }

        /** ***SHOULD BE MODIFIED TO USE CONSTANTS***
        * @notice Decodes underlying data within encoded royaltyVal value.
        * @dev Function called by script to decode underlying data stored within royaltyVal.
        *      Function Selector: 0xf514db49
        * @param _royaltyVal Unsigned interger containing collaborator royalty data.
        */
        function royaltyValDecoder(uint128 _royaltyVal) external pure returns(
            uint8 _zeroVal,
            uint32 _royalty1,
            uint32 _royalty2,
            uint32 _royalty3,
            uint32 _royalty4,
            uint32 _royalty5,
            uint32 _royalty6
        ) {
            if(_royaltyVal < MIN_ENCODED_ROYALTY) {
                revert WavDBC__MinEncodedValueInvalid();
            }
            // Extract _zeroVal
            _zeroVal = uint8((_royaltyVal / 10**36) % 10);
            if(_zeroVal > 1) {
                revert WavDBC__MinEncodedValueInvalid();
            }
            // Extract six 6-digit raw inputs
            _royalty1 = uint32((_royaltyVal / 10**31) % 10**6);
            _royalty2 = uint32((_royaltyVal / 10**25) % 10**6);
            _royalty3 = uint32((_royaltyVal / 10**19) % 10**6);
            _royalty4 = uint32((_royaltyVal / 10**13) % 10**6);
            _royalty5 = uint32((_royaltyVal / 10**7) % 10**6);
            _royalty6 = uint32(_royaltyVal % 10**6);
        }

      
        /**
        * @notice Validates and returns cReleaseVal data specific to a Content Token.
        * @dev Authenticates cReleaseVal data associated to provided hashId input for further use.
        *      Function Selector: 0xc40e145a
        * @param _hashId Identifier of Content Token being queried.
        */
        function validateContentTokenReleaseData(
        bytes32 _hashId
        ) external view returns(
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt
        ) {
            uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
        
            if(_releaseVal != 0) {
               // IF logic here  
               (_startRelease, _endRelease, _preRelease, _pausedAt) = cReleaseValDecoder6(_releaseVal);
               return;
            }

            _releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
        
            if(_releaseVal != 0) {
            // IF logic here
            (_startRelease, _endRelease, _preRelease, _pausedAt) = cReleaseValDecoder6(_releaseVal);
               return; 
            }

            revert WavDBC__InputError404();
        }


        /**
        * @notice Validates and returns a dynamic quantity of cReleaseVal data associated with Content Tokens.
        * @dev Authenticates cReleaseVal data associated to provided hashId values for further use.
        *      Function Selector: 0x341f7875
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        */
        function validateContentTokenReleaseDataBatch(
        bytes32[] calldata _hashIdBatch
        ) external view returns(
            uint96[] memory _startRelease,
            uint96[] memory _endRelease,
            uint96[] memory _preRelease,
            uint8[] memory _pausedAt
        ) {
            uint256 _hashLength = _hashIdBatch.length;
            _startRelease = new uint96[](_hashLength);
            _endRelease = new uint96[](_hashLength);
            _preRelease = new uint96[](_hashLength);
            _pausedAt = new uint8[](_hashLength);

            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
            
            uint96 _packed = ReturnMapping.returnCContentTokenSearch[_hashId];
            
            if(_packed == 0) {
                _packed = ReturnMapping.returnSContentTokenSearch[_hashId];
                if(_packed == 0) revert WavDBC__InputError404();
            }
            
            (_startRelease[i], _endRelease[i], _preRelease[i], _pausedAt[i]) =
                cReleaseValDecoder6(_packed);

                unchecked { ++i; }
            }
        }


        /**
        * @notice Validates and returns a price property instance associated with a ContentToken.
        * @dev Authenticates price data associated with a hashId and numToken value for further use.
        *      Function Selector: 0xa238ed08
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        */
        function validateContentTokenPriceVal(bytes32 _hashId, uint16 _numToken) external view returns(uint256) {
            // _cPriceUsd = <x> encoded value found in sContentToken mapping
            uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
            
            // if <x> value is found and exists...
            if(_cPriceUsd != 0 && _numToken == 0) {
                // Decode <x> encoded value
               uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                return uint256((_cPriceUsdVal));
            }

            _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
            
            if(_cPriceUsd != 0 && _numToken == 0) {
               uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                return uint256((_cPriceUsdVal));

            }
            // If returned sPriceUsdVal of hashId != 0...
            uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);

            if(_sPriceUsdVal != 0 && _numToken != 0) {
                // Gets the encoded priceMap associated with sPriceUsdVal of hashId
                uint256 _priceMap = ReturnMapping.returnContentTokenPriceMap(_hashId);
                // Determines the binary state of the token index
                uint8 _priceState = decode2BitState(_priceMap, _numToken);
                // Decodes the user-defined numerical value correlated to the binary state
                _result = sPriceUsdValState(_priceState, _sPriceUsdVal, _hashId);
                
                return uint256((_result));
            }
        }


        /**
        * @notice Validates and returns a dynamic quantity of price properties associated with ContentTokens.
        * @dev Authenticates price data associated to hashId and numToken values for further use.
        *      Function Selector: 0x0ef120e3
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
        */
         function validateContentTokenPriceValBatch(bytes32[] calldata _hashIdBatch, uint16[] calldata _numTokenBatch) external view returns(uint256[] memory _resultBatch) {
            uint256 _priceLength = _hashIdBatch.length;
            if(_priceLength != _numTokenBatch.length) revert WavDBC__LengthValIssue();
            _resultBatch = new uint256[](_priceLength);

            for(uint256 i = 0; i < _priceLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _numToken = _numTokenBatch.length[i];
                uint256 _resolved;

                // Branch 1 sContentToken; cPriceUsd; numToken[0] only
                uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
                if(_cPriceUsd != 0 && _numToken == 0) {
                    uint32 _decoded1 = cPriceUsdValDecoder(_cPriceUsd);
                    _resolved = uint256(_decoded1);
                }
                else {
                // Branch 2: cContentToken; cPriceUsd; numToken[0] only
                _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
                if(_cPriceUsd != 0 && _numToken == 0) {
                    uint32 _decoded1 = cPriceUsdValDecoder(_cPriceUsd);
                    _resolved = uint256(_decoded1);
                }
                } else {
                    // Branch 3: cContentToken sPriceUsd
                    uint112 _sPriceUsd = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);
                    if(_sPriceUsd != 0 && _numToken != 0) {
                        uint256 _bitMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
                        uint8 _state = decode2BitState(_bitMap, _numToken);
                        _resolved = sPriceUsdValState(_state, _sPriceUsd, _hashId);
    
                    } else {
                        revert WavDBC__InputError404();
                    }
                }
                _resultBatch[i] = _resolved;
                unchecked { ++i; }
            }
            return _resultBatch;

         }


        /**
        * @notice Validates price property, converts to wei, and debits supply. 
        * @dev Authenticates Content Token PreRelease supply and pricing data prior to sale.
        *      Function Selector: 0x8748539f
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
         function _validateDebitPreRelease(
            bytes32 _hashId,
            uint16 _numToken,
            uint112 _quantity
        ) internal returns(uint256) {
            // _cPriceUsd = <x> encoded value found in sContentToken mapping
            uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
            
            // if <x> value is found and exists...
            if(_cPriceUsd != 0 && _numToken == 0) {
                // Decode <x> encoded value
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitPreReleaseSupply(_hashId, _quantity)
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }
             
             _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
            
            if(_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitPreReleaseSupply(_hashId, _quantity);
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }

            // If returned sPriceUsdVal of hashId != 0...
            uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);

            if(_sPriceUsdVal != 0 && _numToken != 0) {
                if(!isTokenEnabled(_hashId, _numToken)) revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
            uint8 _priceState = decode2BitState(_priceMap, _numToken);
            uint256 _usdPrice = sPriceUsdValState(_priceState, _sPriceUsdVal, _hashId);

            // debit tier pre-release supply
            uint8 _tierId = _getTier(_hashId, _numToken);
            sDebitPreReleaseSupply(_hashId, _tierId, _quantity);

            return WavFeed.usdToWei(_usdPrice);

            }
            revert WavDBC__InputError404();
        }


        
        
        
        
        
        
        
        /**
        * @notice Validates dynamic quantity of price properties, converts to wei, and debits supply. 
        * @dev Authenticates Content Token PreRelease supply and pricing data batch prior to sale.
        *      Function Selector: 0xc0984f53
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
        * @param _quantityBatch Total instances of each numToken.
        */
        function _validateDebitPreReleaseBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _numTokenBatch,
            uint112[] calldata _quantityBatch
        ) internal returns(uint256[] memory) {
            uint256 _hashLength = _hashIdBatch.length;
            if(
                _hashLength == 0 ||
                _hashLength != _numTokenBatch.length ||
                _hashLength != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }

            _weiPrice = new uint256[](_hashLength);

            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _numToken = _numTokenBatch[i];
                uint256 _quantity = _quantityBatch[i];

                // Branch 1: SContentToken priceUsdVal
                uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
                if(_cPriceUsd != 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitPreReleaseSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 2: CContentToken cPriceUsdVal
                _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
                if(_cPriceUsd == 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitPreReleaseSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 3: CContentToken sPriceUsdVal
                uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);
                if(_sPriceUsdVal != 0 && _numToken != 0) {
                    uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
                    uint8 _priceState = decode2BitState(_priceMap, _numToken);
                    uint256 _usdPrice = sPriceUsdValState(_priceMap, _sPriceUsdVal, _hashId);

                    uint8 _tierId = _getTier(_hashId, _numToken);
                    sDebitPreReleaseSupply(_hashId, _tierId, _quantity);

                    pricesWei[i] = WavFeed.usdToWei(_usdPrice);
                    unchecked { ++i; }
                    continue;
                }
                revert WavDBC__InputError404();
            }
        }






        /**
        * @notice Validates price property, converts to wei, and debits supply. 
        * @dev Authenticates Content Token WavStore supply and pricing data prior to sale.
        *      Function Selector: 0x6e1da822
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function _validateDebitWavStore(
            bytes32 _hashId,
            uint16 _numToken,
            uint112 _quantity
        ) internal returns(uint256) {
            // _cPriceUsd = <x> encoded value found in sContentToken mapping
            uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
            
            // if <x> value is found and exists...
            if(_cPriceUsd != 0 && _numToken == 0) {
                // Decode <x> encoded value
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitWavStoreSupply(_hashId, _quantity);
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }
             
             _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
            
            if(_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitWavStoreSupply(_hashId, _quantity);
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }

            // If returned sPriceUsdVal of hashId != 0...
            uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);

            if(_sPriceUsdVal != 0 && _numToken != 0) {
            if(!isTokenEnabled(_hashId, _numToken)) revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
            uint8 _priceState = decode2BitState(_priceMap, _numToken);
            uint256 _usdPrice = sPriceUsdValState(_priceState, _sPriceUsdVal, _hashId);

            // debit tier pre-release supply
            uint8 _tierId = _getTier(_hashId, _numToken);
            sDebitWavStoreSupply(_hashId, _tierId, _quantity);

            return WavFeed.usdToWei(_usdPrice);

            }

            revert WavDBC__InputError404();
        }


        /**
        * @notice Validates dynamic quantity of price properties, converts to wei, and debits supply. 
        * @dev Authenticates Content Token WavStore supply and pricing data batch prior to sale.
        *      Function Selector: 0x83b2de3d
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
        * @param _quantityBatch Total instances of each numToken.
        */
        function _validateDebitWavStoreBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _numTokenBatch,
            uint112[] calldata _quantityBatch
        ) internal returns(uint256[] memory _weiPrice) {
            uint256 _hashLength = _hashIdBatch.length;
            if(
                _hashLength == 0 ||
                _hashLength != _numTokenBatch.length ||
                _hashLength != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }

            _weiPrice = new uint256[](_hashLength);

            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _numToken = _numTokenBatch[i];
                uint256 _quantity = _quantityBatch[i];

                // Branch 1: SContentToken priceUsdVal
                uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
                if(_cPriceUsd != 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitWavStoreSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 2: CContentToken cPriceUsdVal
                _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
                if(_cPriceUsd == 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitWavStoreSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 3: CContentToken sPriceUsdVal
                uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);
                if(_sPriceUsdVal != 0 && _numToken != 0) {
                    uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
                    uint8 _priceState = decode2BitState(_priceMap, _numToken);
                    uint256 _usdPrice = sPriceUsdValState(_priceMap, _sPriceUsdVal, _hashId);

                    uint8 _tierId = _getTier(_hashId, _numToken);
                    sDebitWavStoreSupply(_hashId, _tierId, _quantity);

                    pricesWei[i] = WavFeed.usdToWei(_usdPrice);
                    unchecked { ++i; }
                    continue;
                }
                revert WavDBC__InputError404();
            }
        }


        /**
        * @notice Validates price property, converts to wei, and debits supply. 
        * @dev Authenticates Content Token WavReserve supply and pricing data prior to sale.
        *      Function Selector: 0x7b994452
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function _validateDebitWavReserve(
            bytes32 _hashId,
            uint16 _numToken,
            uint112 _quantity
        ) internal returns(uint256) {
            // _cPriceUsd = <x> encoded value found in sContentToken mapping
            uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
            
            // if <x> value is found and exists...
            if(_cPriceUsd != 0 && _numToken == 0) {
                // Decode <x> encoded value
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitWavReserve(_hashId, _quantity)
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }
             
             _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
            
            if(_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                cDebitWavReserve(_hashId, _quantity);
                return WavFeed.usdToWei(uint256(_cPriceUsdVal));
            }

            // If returned sPriceUsdVal of hashId != 0...
            uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);

            if(_sPriceUsdVal != 0 && _numToken != 0) {
                if(!isTokenEnabled(_hashId, _numToken)) revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
            uint8 _priceState = decode2BitState(_priceMap, _numToken);
            uint256 _usdPrice = sPriceUsdValState(_priceState, _sPriceUsdVal, _hashId);

            // debit tier pre-release supply
            uint8 _tierId = _getTier(_hashId, _numToken);
            sDebitWavReserve(_hashId, _tierId, _quantity);

            return WavFeed.usdToWei(_usdPrice);

            }

            revert WavDBC__InputError404();
        }


        /**
        * @notice Validates dynamic quantity of price properties, converts to wei, and debits supply. 
        * @dev Authenticates Content Token WavReserve supply and pricing data batch prior to sale.
        *      Function Selector: 0xb2ebf7f4
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
        * @param _quantityBatch Total instances of each numToken.
        */
        function _validateDebitWavReserveBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _numTokenBatch,
            uint112[] calldata _quantityBatch
        ) internal returns(uint256[] memory _weiPrice) {
            uint256 _hashLength = _hashIdBatch.length;
            if(
                _hashLength == 0 ||
                _hashLength != _numTokenBatch.length ||
                _hashLength != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }

            _weiPrice = new uint256[](_hashLength);

            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _numToken = _numTokenBatch[i];
                uint256 _quantity = _quantityBatch[i];

                // Branch 1: SContentToken priceUsdVal
                uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(_hashId);
                if(_cPriceUsd != 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitWavReserveSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 2: CContentToken cPriceUsdVal
                _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);
                if(_cPriceUsd == 0 && _numToken == 0) {
                    uint32 _cPriceUsdVal = cPriceUsdValDecoder(_cPriceUsd);
                    cDebitWavReserveSupply(_hashId, _quantity);
                    _weiPrice[i] = WavFeed.usdToWei(uint256(_cPriceUsdVal));
                    unchecked { ++i; }
                    continue;
                }

                // Branch 3: CContentToken sPriceUsdVal
                uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(_hashId);
                if(_sPriceUsdVal != 0 && _numToken != 0) {
                    uint256 _priceMap = ReturnMapping.returnCContentTokenPriceMap(_hashId);
                    uint8 _priceState = decode2BitState(_priceMap, _numToken);
                    uint256 _usdPrice = sPriceUsdValState(_priceMap, _sPriceUsdVal, _hashId);

                    uint8 _tierId = _getTier(_hashId, _numToken);
                    sDebitWavReserveSupply(_hashId, _tierId, _quantity);

                    pricesWei[i] = WavFeed.usdToWei(_usdPrice);
                    unchecked { ++i; }
                    continue;
                }
                revert WavDBC__InputError404();
            }
        }



        /**
        * @notice Creates a price map using symbolic binary states for a sPriceUsdVal property of a cContentToken.
        * @dev Takes a dynamic quantity of index values correlated to 2-bit binary states which are attributed in chronological order.
        *      Function Selector: 0x1e310e88
        * @param _indexArray Total quantity of index values stored as numToken property data.
        * @param _stateArray Correlating quantity of symbolic bit states attributed numerical user-defined price value(s). 
        */
        function encode2BitStates(uint16[] calldata _indexArray, uint8[] calldata _stateArray) external pure returns(uint256 _resultVal) {
            if(
                _indexArray.length != _stateArray.length ||
                _indexArray.length < 1 ||
                _indexArray.length > 127) {
                revert WavDBC__LengthValIssue();
            }
            _resultVal = 0;

            for(uint256 i = 0; i < _indexArray.length; ++i) {
                uint8 _index = _indexArray[i];
                uint8 _state = _stateArray[i];
                if(_index >= 128 || _state >= 4) {
                    revert WavDBC__BitValIssue();
                }
                // Prepare math to clear bits at index
                uint256 _mask = ~(uint256(0x3)) << (2 * _index);
                // Insert 2-bit value
                uint256 _encodedVal = uint256(_state) << (2 * _index);
                // Clear existing bits at index, insert new value
                _resultVal = (_resultVal & _mask) | _encodedVal;
            }
            // Ensures one or more index is non-zero bitstate
            if(_resultVal == 0) {
                revert WavDBC__MinEncodedValueInvalid();
            }

            return _resultVal;
        }


        /**
        * @notice Decodes and returns binary state of numToken value from valid encoded bitMap.
        * @dev Takes an encoded priceMap property and returns binary state of specified numToken index.
        *      Function Selector: 0x1e310e88
        * @param _bitMap priceMap associated with cContentToken.
        * @param _numToken numToken index being queried.
        */
        function decode2BitState(uint256 _bitmap, uint16 _numToken) external pure returns(uint8 _value) {
            if(_numToken > 128) {
                revert WavDBC__LengthValIssue();
            }
            return uint8((_bitmap >> (2 * _numToken)) & 0x3);
        }

        function encode3BitState(uint16[] calldata _indexArray, uint8[] calldata _stateArray) external pure returns(uint256 _bitmap) {
            if(
                _indexArray.length != _stateArray.length ||
                _indexArray.length < 1 ||
                _indexArray.length > 85
            ) {
                revert WavDBC__LengthValIssue();
            }

            uint256 _result = 0;
            for(uint256 i = 0; i < _indexArray.length; ++i) {
                uint16 _index = _indexArray[i];
                uint8 _state = _stateArray[i];

                if(_index >= 85 || _state >= 8) {
                    revert WavDBC__BitValIssue();
                }

                uint256 _mask = ~(uint256(0x7) << (3 * _index));
                uint256 _insert = uint256(_state) << (3 * _index);

                _result = (_result & _mask) | _insert;
            }
            
            if(_result == 0) {
                revert WavDBC__MinEncodedValueInvalid();
            }

            return _result;

        }

        function decode3BitState(uint256 _bitmap, uint16 _numToken) external pure returns(uint8 _value) {
            if(_numToken >= 85) {
                revert WavDBC__LengthValIssue();
            }
            return uint8((_bitmap >> (3 * _numToken)) & 0x7);
        }

        /**
        * @notice Returns the tier index of specified numToken in relation to hashId.
        * @dev Reads 256-bit word that contains 4-bit tier slot for 64 tokens, extracts 4-bit value attributed to numToken input.
        *      Function Selector: 0x2be87751
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        */
        function getTier(bytes32 _hashId, uint16 _numToken) external view returns(uint8) {
            uint16 _wordIndex = _numToken >> 6;
            uint8 _within = uint8(_numToken & 63);

            uint256 _packed = s_tierMap[_hashId][_wordIndex];
            // 4 bits per token
            uint256 _shift = uint256(_within) * 4; 
            uint8 _tierId = uint8((_packed >> _shift) & 0xF);

            return _tierId;
        }

        /**
        * @notice Validates seperate sale availability of provided numToken input in relation to hashId.
        * @dev Reads s_enableBitmap and verifies corresponding bit-state of numToken.
        *      Function Selector: 0x7f4395f3
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        */
        function tokenEnabledState(bytes32 _hashId, uint16 _numToken) internal view returns(bool) {
            uint16 _wordIndex = _numToken >> 8;
            uint16 _within = _numToken & 255;

            uint256 _packed = s_enableBitmap[_hashId][_wordIndex];
            return ((_packed >> _within) & 1) == 1;
        }

        
        
        // THIS FUNCTION COULD AND SHOULD BE MADE MUCH BETTER IMO

        /**
        * @notice Partitions gross revenue into collaborator reserve.
        * @dev Accesses Collaborator struct and debits earnings based on relevant royalty split
        *      Function Selector: 0x784c9669
        * @param _hashId Identifier of Content Token being queried.
        * @param _numToken Content Token identifier used to specify the token index being queried.
        * @param _grossWei Total available ETH share.
        */
        function _allocateCollaboratorReserve(
            bytes32 _hashId,
            uint16 _numToken,
            uint256 _grossWei
        ) internal returns(uint256 _netWei) {
            if(_grossWei == 0) return 0;

            CollaboratorStructStorage.Collaborator storage CollaboratorStruct =
            CollaboratorStructStorage.collaboratorMapStorage();
            
            CollaboratorStructStorage.Collaborator storage meta = CollaboratorStruct.s_collaborators[_hashId];
            uint8 _numCollaborators = CollaboratorStruct.numCollaborator;
            uint128 _royaltyVal = CollaboratorStruct.royaltyVal;

            uint8 _tokenState = encode3BitState(_hashId, _numToken);
            
            if(
                _numCollaborators == 0 ||
                _tokenState == 0
            ) {
                // Collaborators disabled for numToken
                return _creatorGrossWei;
            }

            (, uint32 r1, uint32 r2, uint32 r3, uint32 r4, uint32 r5, uint32 r6) = royaltyValDecoder(_royaltyVal);
            if(_tokenState == 1) _selectedSlot = r1;
            else if (_tokenState == 2) _selectedSlot = r2;
            else if (_tokenState == 3) _selectedSlot = r3;
            else if (_tokenState == 4) _selectedSlot = r4;
            else if (_tokenState == 5) _selectedSlot = r5;
            else _selectedSlot = r6;
            

            if(_selectedSlot == 0) return _grossWei;

            uint256 collaboratorReserveWei = (_grossWei * uint256(_selectedSlot)) / uint256(CRELEASE_6_MAX);

            if(_collaboratorReserveWei > _grossWei) {
                _collaboratorReserveWei = _grossWei;
            }

            s_collaboratorReserve[_hashId][_numToken] += _collaboratorReserveWei;

            _netWei = _grossWei - _collaboratorReserveWei;
            return _creatorRemainderWei;
            
        }


        /**
        * @notice Deducts quantity of WavStore supply and updates the encoded value.
        * @dev Reads s_cWavSupplies and updates active encoded WavStore supply of hashId.
        *      Function Selector: 0x5a552e46
        * @param _hashId Identifier of Content Token being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function cDebitWavStoreSupply(
            bytes32 _hashId,
            uint112 _quantity
        ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _wavStoreSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _wavStoreSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;

        }

        /**
        * @notice Deducts batch quantity of WavStore supply and updates the encoded value.
        * @dev Reads s_cWavSupplies and updates active encoded WavStore supply of hashId.
        *      Function Selector: 0xf81676f8
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
        */
        function cDebitWavStoreSupplyBatch(
            bytes32[] calldata _hashIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(_hashIdBatch.length != _quantityBatch.length) {
                revert WavDBC__LengthValIssue();
            }

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            for(uint256 i = 0; i < _hashIdBatch.length; ++i) {
                bytes32 _hashId = _hashIdBatch[i];
                uint112 _quantity = _quantityBatch[i];
                
                uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                remainingSupplyDecoder(_remainingSupplies);

                if(_quantity == 0 || _wavStoreSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _wavStoreSupply -= _quantity;

                uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                )
                
                ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;
            }
        }

        /**
        * @notice Deducts quantity of WavStore supply tier and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded WavStore supply tier of hashId.
        *      Function Selector: 0x74750c49
        * @param _hashId Identifier of Content Token being queried.
        * @param _tierId Tier index attributed to numToken of CContentToken hashId.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function sDebitWavStoreSupply(
            bytes32 _hashId,
            uint16 _tierId,
            uint112 _quantity
            ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _wavStoreSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _wavStoreSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupplies;
        }


       /**
        * @notice Deducts batch quantity of WavStore supply and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded WavStore supply of hashId.
        *      Function Selector: 0x58d94600
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
        */
        function sDebitWavStoreSupplyBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _tierIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(
                _hashIdBatch.length == 0 ||
                _hashIdBatch.length != _tierIdBatch.length ||
                _hashIdBatch.length != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint256 _hashLength = _hashIdBatch.length;
            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _tierId = __tierIdBatch[i];
                uint112 _quantity = _quantityBatch[i];

                uint112 _remainingSupply = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                cRemainingSupplyDecoder(_remainingSupply);

                if(_quantity == 0 || _wavStoreSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _wavStoreSupply -= _quantity;

                uint112 _updatedRemainingSupply = cRemainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                );

                ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupply;

                unchecked { ++i; }
            }
        }


        /**
        * @notice Deducts quantity of WavReserve supply and updates the encoded value.
        * @dev Reads s_cWavSupplies and updates active encoded WavReserve supply of hashId.
        *      Function Selector: 0x21373ff6
        * @param _hashId Identifier of Content Token being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function cDebitWavReserve(
            bytes32 _hashId,
            uint112 _quantity
        ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _wavReserveSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _wavReserveSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;
        }


        /**
        * @notice Deducts batch quantity of WavReserve supply and updates the encoded value.
        * @dev Reads s_cWavSupplies and updates active encoded WavReserve supply of hashId.
        *      Function Selector: 0xa570fed4
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _quantityBatch Instances of each Content Token being purchased.
        */
        function cDebitWavReserveSupplyBatch(
            bytes32[] calldata _hashIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(_hashIdBatch.length != _quantityBatch.length) {
                revert WavDBC__LengthValIssue();
            }

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            for(uint256 i = 0; i < _hashIdBatch.length; ++i) {
                bytes32 _hashId = _hashIdBatch[i];
                uint112 _quantity = _quantityBatch[i];
                
                uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                remainingSupplyDecoder(_remainingSupplies);

                if(_quantity == 0 || _wavReserveSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _wavReserveSupply -= _quantity;

                uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                )
                
                ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;
            }
        }


        /**
        * @notice Deducts quantity of WavReserve supply tier and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded WavReserve supply tier of hashId.
        *      Function Selector: 0x40cb439e
        * @param _hashId Identifier of Content Token being queried.
        * @param _tierId Tier index attributed to numToken of CContentToken hashId.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function sDebitWavReserve(
            bytes32 _hashId,
            uint16 _tierId,
            uint112 _quantity
        ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _wavReserveSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _wavReserveSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupplies;
        }


        /**
        * @notice Deducts batch quantity of WavReserve supply and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded WavReserve supply of hashId.
        *      Function Selector: 0xf78b6d55
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
        */
        function sDebitWavReserveBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _tierIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(
                _hashIdBatch.length == 0 ||
                _hashIdBatch.length != _tierIdBatch.length ||
                _hashIdBatch.length != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint256 _hashLength = _hashIdBatch.length;
            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _tierId = __tierIdBatch[i];
                uint112 _quantity = _quantityBatch[i];

                uint112 _remainingSupply = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                cRemainingSupplyDecoder(_remainingSupply);

                if(_quantity == 0 || _wavReserveSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _wavReserveSupply -= _quantity;

                uint112 _updatedRemainingSupply = cRemainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                );

                ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupply;

                unchecked { ++i; }
            }
        }


        /**
        * @notice Deducts quantity of PreRelease supply and updates the encoded value.
        * @dev Reads s_cWavSupplies and updates active encoded PreRelease supply of hashId.
        *      Function Selector: 0xbeaa0e21
        * @param _hashId Identifier of Content Token being queried.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function cDebitPreReleaseSupply(
            bytes32 _hashId,
            uint112 _quantity
        ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();
            
            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _preReleaseSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _preReleaseSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;
        }


        /**
        * @notice Deducts batch quantity of PreRelease supply and updates the encoded value.
        * @dev Reads c_cWavSupplies and updates active encoded PreRelease supply of hashId.
        *      Function Selector: 0x8533eed8
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
        */
        function cDebitPreReleaseSupplyBatch(
            bytes32[] calldata _hashIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(_hashIdBatch.length != _quantityBatch.length) {
                revert WavDBC__LengthValIssue();
            }

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            for(uint256 i = 0; i < _hashIdBatch.length; ++i) {
                bytes32 _hashId = _hashIdBatch[i];
                uint112 _quantity = _quantityBatch[i];
                
                uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                remainingSupplyDecoder(_remainingSupplies);

                if(_quantity == 0 || _preReleaseSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _preReleaseSupply -= _quantity;

                uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                )
                
                ContentTokenSupplyMapStruct.s_cWavSupplies[_hashId] = _updatedRemainingSupplies;
            }
        }


        /**
        * @notice Deducts quantity of PreRelease supply tier and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded PreRelease supply tier of hashId.
        *      Function Selector: 0x58b030c2
        * @param _hashId Identifier of Content Token being queried.
        * @param _tierId Tier index attributed to numToken of CContentToken hashId.
        * @param _quantity Value being deducted from relevant remaining supply source.
        */
        function sDebitPreReleaseSupply(
            bytes32 _hashId,
            uint16 _tierId,
            uint112 _quantity
            ) internal {
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint112 _remainingSupplies = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];

            (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
            remainingSupplyDecoder(_remainingSupplies);

            if(
                _quantity == 0 ||
                _preReleaseSupply < _quantity
            ) {
                revert WavDBC__NumInputInvalid();
            }

            _preReleaseSupply -= _quantity;

            uint112 _updatedRemainingSupplies = remainingSupplyEncoder(
                _wavStoreSupply,
                _wavReserveSupply,
                _preReleaseSupply
            );

            // store _updatedRemainingSupplies
            ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupplies;
            
            }


        /**
        * @notice Deducts batch quantity of PreRelease supply and updates the encoded value.
        * @dev Reads s_sWavSupplies and updates active encoded PreRelease supply of hashId.
        *      Function Selector: 0xf38c013b
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
        */
        function sDebitPreReleaseBatch(
            bytes32[] calldata _hashIdBatch,
            uint16[] calldata _tierIdBatch,
            uint112[] calldata _quantityBatch
        ) internal {
            if(
                _hashIdBatch.length == 0 ||
                _hashIdBatch.length != _tierIdBatch.length ||
                _hashIdBatch.length != _quantityBatch.length
            ) {
                revert WavDBC__LengthValIssue();
            }
            
            ContentTokenSupplyMapStorage.ContentTokenSupplyMap storage ContentTokenSupplyMapStruct =
            ContentTokenSupplyMapStorage.contentTokenSupplyMapStorage();

            uint256 _hashLength = _hashIdBatch.length;
            for(uint256 i = 0; i < _hashLength;) {
                bytes32 _hashId = _hashIdBatch[i];
                uint16 _tierId = __tierIdBatch[i];
                uint112 _quantity = _quantityBatch[i];

                uint112 _remainingSupply = ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId];
                (uint112 _wavStoreSupply, uint112 _wavReserveSupply, uint112 _preReleaseSupply) =
                cRemainingSupplyDecoder(_remainingSupply);

                if(_quantity == 0 || _preReleaseSupply < _quantity) {
                    revert WavDBC__NumInputInvalid();
                }

                _preReleaseSupply -= _quantity;

                uint112 _updatedRemainingSupply = cRemainingSupplyEncoder(
                    _wavStoreSupply,
                    _wavReserveSupply,
                    _preReleaseSupply
                );

                ContentTokenSupplyMapStruct.s_sWavSupplies[_hashId][_tierId] = _updatedRemainingSupply;

                unchecked { ++i; }
            }
        }

        /**
        * @notice Provides current timestamp in an hour-based format.
        * @dev Generates timestamp in more compact format
        *      Function Selector: 0xd949adee
        */
        function currentHourStamp() external view returns(uint96 _hourStamp) {
            uint96 _timeStamp = uint96(block.timestamp);
            _timeStamp / SECOND_TO_HOUR_PRECISION = _hourStamp;
            return _hourStamp;
        }













    // END OF JULY 31 2025 NEW FUNCTION / REWRITES


    // ALL BELOW FUNCTIONS OUTDATED, REPLACED, AND TO LIKELY BE ENTIRELY DEPRECATED









    /**
     * @notice Routes dynamic quantity of values to determined bit-system.
     * @dev Measures length of total numerical inputs defined, routes for further interpretation.
     * @param _inputVal numerical array of creator-defined inputs.
     */
    function tokenBSDetermine(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {
        if (_inputVal.length == 1) {
            return token0BSInterpreter(_inputVal);
        } else if (_inputVal.length == 2) {
            return token1BSInterpreter(_inputVal);
        } else if (_inputVal >= 3 && _inputVal.length <= 4) {
            return token2BSInterpreter(_inputVal);
        } else if (_inputVal.length > 4 && _inputVal.length <= 8) {
            return token3BSInterpreter(_inputVal);
        } else {
            revert WavDBC__LengthValIssue();
        }
    }

    /** 0-bit possibilities: (1: Fully disabled state (0)) (2: 'Fully' enabled state, set to defined value)
    *Low hanging fruit* store single value, bitmap can be assigned to all possible tokens in same var
    
     */

    function token0BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {}

    /**
     * @notice Interprets input values using a 1-bit system and compacts them.
     * @dev Formats values to six digits, appends bit-state identifiers, and compacts them into a single uint256.
     * @param _inputValArray numerical array of input values.
     * @return uint256 representing the compacted values.
     */
    function token1BSInterpreter(
        uint256[] memory _inputValArray
    ) public pure returns (uint256) {
        bool has0Val = detect0Val(_inputValArray);
        uint256[] memory appendVals = assign1BIdentifiers(_inputValArray);

        // Check if the last value is 0Val and format if needed
        if (has0Val) {
            appendVals = format1BZeroVal(appendVals);
        }

        // Compact the values
        uint256 result = (appendVals[0] * 10000000) + appendVals[1];

        return result;
    }

    /**
     * @notice Interprets input data following a 2-bit system.
     * @dev Appends bit-state IDs, and formats returned input into singular compacted value.
     * @param _inputVal numerical array of input values.
     * @return uint256 representing compacted value.
     */
    function token2BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {
        uint256[] memory appendVals = process2BState(_inputVal);
        uint256 result = 0;

        for (uint256 i = 0; i < appendVals.length; i++) {
            result = (result * 100000000) + appendVals[i];
        }

        return result;
    }

    function token3BSInterpreter(
        uint256[] memory _inputVal
    ) public pure returns (uint256) {}

    /**
     * @notice Processes input values by delegating operations to sub-functions.
     * @dev Delegates inputs for bit-state assignment, and properly formats them for further compaction.
     * @param _inputVal numerical array of input values.
     * @return uint256[] of input values appended with bit-state identifiers.
     */
    function process2BState(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        if (_inputVal.length < 3 && _inputVal.length > 4) {
            revert WavDBC__LengthValIssue();
        }

        bool has0Val = detect0Val(_inputVal);
        uint256[] memory appendVals = append2BState(_inputVal);

        if (has0Val) {
            appendVals = format2BZeroVal(appendVals);
        }

        return appendVals;
    }

    /**
     * @notice Formats values to six digits and appends numerical 1-bit state identifiers.
     * @dev Formats each value to six digits, multiplies by 10, and adds corresponding 1-bit state identifier (0 or 1).
     * @param _rInput numerical array of values to which 1-bit state identifiers are appended.
     * @return array of values with formatted and appended 1-bit state identifiers.
     */
    function assign1BIdentifiers(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        uint256[] memory appendedValues = new uint256[](_inputVal.length);
        uint256[2] memory bitStates = [0, 1];

        for (uint256 i = 0; i < _inputVal.length; i++) {
            appendedValues[i] = (_inputVal[i] * 10) + bitStates[i];
        }

        return appendedValues;
    }

    /**
     * @notice Directly assigns numerical bit-state IDs to user-inputs.
     * @dev Multiplies each value by 100 and adds corresponding bit-state identifier.
     * @param _inputVal numerical array of values to which bit-state identifiers are appended.
     * @return array of values with appended bit-state identifiers.
     */
    function assign2BState(
        uint256[] memory _inputVal
    ) public pure returns (uint256[] memory) {
        uint256[] memory appendVals = new uint256[](_inputVal.length);
        uint256[4] memory bitStateId = [0, 1, 10, 11];
        uint256 bitIndex = 0;

        for (uint256 i = 0; i < _inputVal.length; i++) {
            appendVals[i] = (_inputVal[i] * 100) + bitStateId[bitIndex];
            bitIndex++;

            if (bitIndex == 3 && _inputVal.length == 3) {
                bitIndex++;
            }
        }
        if (bitIndex < 4) {
            appendVals[_inputVal.length - 1] =
                appendVals[_inputVal.length - 1] *
                100 +
                bitStateId[bitIndex];
        }

        return appendVals;
    }

    /**
     * @notice Finalizes the appended values by ensuring 0Val is correctly formatted for 1-bit system.
     * @dev Checks if the last value is 0Val and formats it accordingly.
     * @param appendedValues numerical array of values with appended 1-bit state identifiers.
     * @return array of finalized values.
     */
    function format1BZeroVal(
        uint256[] memory appendedValues
    ) public pure returns (uint256[] memory) {
        uint256 lastIndex = appendedValues.length - 1;
        if (appendedValues[lastIndex] == 1) {
            // Checks if the last value is 0Val
            appendedValues[lastIndex] = 1; // Set 0Val as '0000001'
        }
        return appendedValues;
    }

    /**
     * @notice Ensures 0Val is correctly formatted within an input array.
     * @dev Checks if the last value is 0Val and formats it to '00000011'.
     * @param appendVals numerical array of values with appended bit-state identifiers.
     * @return array of finalized values.
     */
    function format2BZeroVal(
        uint256[] memory appendVals
    ) public pure returns (uint256[] memory) {
        uint256 lastIndex = appendVals.length - 1;
        if (appendVals[lastIndex] / 100 == 0) {
            // Checks if the last value is 0Val
            appendVals[lastIndex] = 11; // Set 0Val as '00000011'
        }
        return appendVals;
    }

    /**
     * @notice Detects presence of 0Val representing undefined and disabled content-states.
     * @dev Inspects numerical array for presence of a 0Val.
     * @param _inputVal numerical array of values to be inspected.
     */
    function detect0Val(uint256[] memory _inputVal) public pure returns (bool) {
        for (uint256 i = 0; i < _inputVal.length; i++) {
            if (_inputVal[i] == 0) {
                return true;
            }
        }
        return false;
    }

    /**
     * @notice Assigns a value to enabled flag positions based on 3-bit encoding.
     * @dev Returns bitmap of defined flag states as a chronologically ordered array.
     * @param _typVal Active 3-bit TYP states (string-type).
     * @param _salVal Active 3-bit SAL states (string-type).
     * @param _spyVal Active 3-bit SPY states (string-type).
     * @param _xtrVal Active 3-bit XTR states (string-type).
     * @return _bitVal Complete 3-bit active functional state-map (string-type).
     */
    function flagStateCat(
        string memory _typVal,
        string memory _salVal,
        string memory _spyVal,
        string memory _xtrVal
    ) internal pure returns (string memory _bitVal) {
        // Concatenate the string bitstates from all categories
        string memory _bitVal = string(
            abi.encodePacked(_typVal, _salVal, _spyVal, _xtrVal)
        );

        return _bitVal;
    }

    /**
     * @notice Ensures basic TYP flag format.
     * @dev Returns bitmap of defined flag states as singular compact value.
     * @param _bitStrings numerical array of defined bit position states.
     */
    function processTYPState(
        string[] memory _bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 3) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1], bitStrings[2])
        );

        return combinedString;
    }

    function processSALState(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function processSPYStates(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function processXTRStates(
        string[] memory bitStrings
    ) internal pure returns (string memory) {
        if (bitStrings.length != 2) {
            revert WavDBC__LengthValIssue();
        }

        // Concatenate the string bitstates without packing
        string memory combinedString = string(
            abi.encodePacked(bitStrings[0], bitStrings[1])
        );

        return combinedString;
    }

    function creatorTokenFormation(
        address _contentId,
        uint256 _creatorId
    ) public pure returns(CreatorToken memory) {
        CreatorToken memory CRET = new CreatorToken({
            creatorId: _creatorId,
            contentId: _contentId,
            isOwner: true
        });
        return CRET;
    }

    function contentTokenFormation(
        uint16 _numAudio
        uint256 _supplyVal,
        uint256 _priceVal,
        uint256 _releaseVal,
        uint256 _bitVal
    ) public pure returns(ContentToken memory) {
        ContentToken CTKN = new ContentToken({
            numAudio: _numAudio,
            supplyVal: _supplyVal,
            priceVal: _priceVal,
            releaseVal: _releaseVal,
            bitVal: _bitVal
        });
        return CONT;
    }
}
