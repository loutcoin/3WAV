// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Operating on Polygon zkEVM for L2 reduced gas fees.
Using ETH as payment leveraging trust, & pre-existing common understanding associated with ETH.
-
~ General Timeline:
Finish back-end foundation => unit, fuzz, integration testing => Polygon zkEVM testnet deployment + front-end integration ==
Functional portfolio iteration => job camp + continue improving where possible => (once thoroughly vetted/iterated) => market release
-
[Personal Reference- Order of OP:
constructor

receive function (if exists)

fallback function (if exists)

external

public

internal

private

Within grouping, view and pure functions last.]
*/
import {WavRoot} from "../src/WavRoot.sol";
import {WavFortress} from "../src/WavFortress.sol";
import {WavAccess} from "../src/WavAccess.sol";
import {WavFeed} from "../src/WavFeed.sol";
import {WavToken} from "../src/WavToken.sol";
import {WavDBC} from "../src/WavDBC.sol";

import {AuthorizedAddrs} from "../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrs.sol";
// CreatorToken
import {CreatorTokenStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {CreatorTokenMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {TokenBalanceStorage} from "../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";
import {CreatorProfitStorage} from "../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";
// ContentToken
import {SpecialLimitedSalesMap} from "../src/Diamond__Storage/ContentToken/Optionals/SpecialLimitedSalesMap.sol";
import {ContentTokenSearchStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
//Helpers
import {ReturnMapping} from "../src/3WAVi__Helpers/ReturnMapping.sol";
import {ReturnValidation} from "../src/3WAVi__Helpers/ReturnValidation.sol";

contract WavStore is WavRoot {
    WavToken WAVT;

    event PreSalePausing(bytes32 indexed _hashId, uint256 indexed _pausedAt);

    event PreSaleResume(bytes32 indexed _hashId);

    event WavSaleSingle(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint256 _purchaseQuantity
    );

    event WavSaleBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint256[] _purchaseQuantity
    );

    event WavResaleSale(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken
        uint256 _purchaseQuantity
    );

     event WavResaleBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint256[] _purchaseQuantity
    );

    event PostManualEndRelease(
        bytes32 indexed _hashId,
        uint96 indexed _updatedEndRelease
    );

     event PreReleaseSale(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint256 _purchaseQuantity
    );

    event PreReleaseBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint256[] _purchaseQuantity
    );

    event PreReleaseState(
        bytes32 indexed _hashId,
        uint8 indexed _inputState
    );

    event PreReleaseStateBatch(
        bytes32[] _hashIdBatch,
        uint8[] _inputStateBatch
    );


    error WavStore__HashResultInvalid();
    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__InsufficientTokenSupply();
    error WavStore__PreSaleNotFound();
    error WavStore__InputStateInEffect();
    error WavStore__InputError404();
    error WavStore__LengthMismatch();
    error WavStore__InputInvalid();
    error WavStore__InvalidSale();
    error WavStore__Immutable();


    constructor(address _wavAccess) {
        s_WavAccess = _wavAccess;
        s_lout = msg.sender;
    }

    /** ***** MAKE SURE THIS ENSURES PRERELEASE IS CURRENTLY ACTIVE (preReleaseValidation)
     * @notice Allows manual intervention to pause or resume an active preRelease sale.
     * @dev The input state is '0' by default. An input state of '1' indicates a paused sale state.
     * @param _hashId Identifier of Content Token being queried.
     * @param _inputState Value affecting sale state of Content Token.
     */
    function preReleaseState(bytes32 _hashId, uint8 _inputState) external {
        ReturnValidation.returnIsAuthorized();

        if(_inputState > 1) revert WavStore__InputInvalid();

        // cContentToken branch
        uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
        if(_releaseVal != 0) {
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_releaseVal);

            // Only allow pause if preSale is currently active, only allow resume if preSale is paused
            if((_inputState == 1 && _pausedAt != 0) || (_inputState == 0 && _pausedAt != 1)) revert WavStore__InputStateInEffect();
            // Activate _pausedAt state and encode
            uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                _startRelease,
                _endRelease,
                _preRelease,
                _inputState
            );

            // Write into cContentToken storage
            CContentTokenStorage.CContentToken storage CContentTokenStruct =
            CContentTokenStorage.cContentTokenStructStorage();
            CContentTokenStruct.cReleaseVal = _updatedReleaseVal;

            emit PreReleaseState(_hashId, _inputState);
            return
        }
        // sContentToken branch
        // sContentToken branch
        _releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);

        if(_releaseVal != 0) {
            // Decode
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_releaseVal);

           // Only allow pause if preSale is currently active, only allow resume if preSale is paused
            if((_inputState == 1 && _pausedAt != 0) || (_inputState == 0 && _pausedAt != 1)) revert WavStore__InputStateInEffect();

            // Activate _pausedAt state and encode
            uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                _startRelease,
                _endRelease,
                _preRelease,
                _inputState
            );

            SContentTokenStorage.SContentToken storage SContentTokenStruct =
            SContentTokenStorage.sContentTokenStructStorage();
            SContentTokenStruct.releaseVal = _updatedReleaseVal;

            emit PreReleaseState(_hashId, _inputState);
            return;
        }
        // Content Token not found in either storage location
        revert WavStore__InputError404();    
    }


    /**
     * @notice Allows manual intervention to pause or resume a plurality of active preRelease sales
     * @dev The input state is '0' by default. An input state of '1' indicates a paused sale state.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _inputStateBatch Batch of values affecting PreRelease sale states of Content Tokens.
     */
    function preReleaseStateBatch(
        bytes32[] calldata _hashIdBatch,
        uint8[] calldata _inputStateBatch
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;
        if(_hashLength == 0 || _inputStateBatch.length != _hashLength) revert WavStore__LengthMismatch();

        // Validate input states
        for(uint256 i = 0; i < _hashLength;) {
            if(_inputStateBatch[i] > 1) revert WavStore__InvalidInputState();
            unchecked { ++i; }
        }
        // Batch releaseVal data validation
        (
            uint96[] memory _startReleaseBatch,
            uint96[] memory _endReleaseBatch,
            uint96[] memory _preReleaseBatch,
            uint8[] memory _pausedAtBatch
        ) = WavDBC.validateContentTokenReleaseDataBatch(_hashIdBatch);

        // Build updated _pausedAt batch
        uint8[] memory _updatedPausedAtBatch = new uint8[](_hashLength);
        for(uint i = 0; i < _hashLength;) {
            uint8 _pausedAt = _pausedAtBatch[i];
            uint8 _updatedPausedAt = _inputStateBatch[i];

            // Only allow pause if preSale is currently active, only allow resume if preSale is paused
            if((_inputState == 1 && _pausedAt != 0) || (_inputState == 0 && _pausedAt != 1)) {
                revert WavStore__InputStateInEffect();
            } 
            _updatedPausedAtBatch[i] = _updatedPausedAt;
            unchecked { ++i; }
        }
        // Encode releaseVal data in batch
        uint96[] memory _updatedReleaseValBatch = WavDBC.cReleaseValEncoderBatch6(
            _startReleaseBatch,
            _endReleaseBatch,
            _preReleaseBatch
            _updatedPausedAtBatch
        );
        // Write back into correct branch by checking storage presence
        for(uint256 i = 0; i < _hashLength;) {
            bytes32 _hashId = _hashIdBatch[i];
            uint96 _updatedReleaseVal  = _updatedReleaseValBatch[i];

            uint96 _returnData = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
            if(_checkCContentToken != 0) {
                 // Write into cContentToken storage
            CContentTokenStorage.CContentToken storage CContentTokenStruct =
            CContentTokenStorage.cContentTokenStructStorage();
            CContentTokenStruct.cReleaseVal = _updatedReleaseVal;
            unchecked { ++i; }
            continue;
            }
            // make sure can just reuse _returnData
            _returnData = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
            if(_returnData != 0) {
                SContentTokenStorage.SContentToken storage SContentTokenStruct =
                SContentTokenStorage.sContentTokenStructStorage();
                SContentTokenStruct.releaseVal = _updatedReleaseVal;
                unchecked { ++i; }
                continue;
            }
            // Should not happen because validateContentTokenReleaseDataBatch should revert
            // In place just as simple extra defensive check
            revert WavStore__InputError404();
        }
            // Emit single batch event
            emit PreReleaseStateBatch(_hashIdBatch, _inputStateBatch); 
        }
    
    
    /**
     * @notice Allows definition of an _endRelease date for a Content Token post-publication.
     * @dev Mandatory minimum of 72-hour window before _endRelease may be executed.
     * @param _hashId Identifier of Content Token being queried.
     * @param _disablePeriod Quantity of hours until _endRelease takes effect.
     */
    function postManualEndRelease(bytes32 _hashId, uint96 _disablePeriod) external {
        ReturnValidation.returnIsAuthorized();

        // Minimum enforced _endRelease execution window (72 hours)
        if(_disablePeriod < 72) revert WavStore__InputInvalid();

        // load current hour stamp once
        uint96 _hourStamp = WavDBC.currentHourStamp();

        // cContentToken Branch
        uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(_hashId);

        if(_releaseVal != 0) {
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_releaseVal);

            // Only allow scheduling if _endRelease undefined
            if(_endRelease != 0) revert WavStore__Immutable();

            // Compute _updatedEndRelease
            uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

            // Create, validate, encode _updatedReleaseVal
            uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                _startRelease,
                _updatedEndRelease,
                _preRelease,
                _pausedAt
            );

            // Write into cContentToken storage
            CContentTokenStorage.CContentToken storage CContentTokenStruct =
            CContentTokenStorage.cContentTokenStructStorage();
            CContentTokenStruct.cReleaseVal = _updatedReleaseVal;

            emit PostManualEndRelease(_hashId, _updatedEndRelease);
            return;
        }
        // sContentToken branch
        _releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);

        if(_releaseVal != 0) {
            // decode
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_releaseVal);

            // Only allow scheduling if _endRelease undefined
            if(_endRelease != 0) revert WavStore__Immutable();

            // Compute _updatedEndRelease
            uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

            // Create, validate, encode _updatedReleaseVal
            uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                _startRelease,
                _updatedEndRelease,
                _preRelease,
                _pausedAt
            );
            SContentTokenStorage.SContentToken storage SContentTokenStruct =
            SContentTokenStorage.sContentTokenStructStorage();
            SContentTokenStruct.releaseVal = _updatedReleaseVal;

            emit PostManualEndRelease(_hashId, _updatedEndRelease);
            return;
        }
        // Content Token not found in either storage location
        revert WavStore__InputError404();
    }


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
        if(_hashLength < 2 || _disablePeriodBatch.length != _hashLength) revert WavStore__LengthMismatch();

        for(uint256 i = 0; i < _hashLength;) {
            if(_disablePeriodBatch[i] < 72) revert WavStore__InputInvalid();
            unchecked { ++i; }
        }

        // Load hourStamp
        uint96 _hourStamp = WavDBC.currentHourStamp();

        for(uint256 i = 0; i < _hashLength;) {
            bytes32 _hashId = _hashIdBatch[i];
            uint96 _disablePeriod = _disablePeriodBatch[i];

            // cContentToken Branch
            uint96 _releaseVal = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
            if(_releaseVal != 0) {
                (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_releaseVal);

            // Only allow scheduling if _endRelease undefined
            if(_endRelease != 0) revert WavStore__Immutable();

            // Compute _updatedEndRelease
            uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

            // Create, validate, encode _updatedReleaseVal
            uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                _startRelease,
                _updatedEndRelease,
                _preRelease,
                _pausedAt
            );

            // Write into cContentToken storage
            CContentTokenStorage.CContentToken storage CContentTokenStruct =
            CContentTokenStorage.cContentTokenStructStorage();
            CContentTokenStruct.cReleaseVal = _updatedReleaseVal;
            unchecked { ++i; }
            continue;
            }
            
            uint96 _releaseVal = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
            if(_releaseVal != 0) {
                // decode
                (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
                WavDBC.cReleaseValDecoder6(_releaseVal);

                // Only allow scheduling if _endRelease undefined
                if(_endRelease != 0) revert WavStore__Immutable();

                // Compute _updatedEndRelease
                uint96 _updatedEndRelease = _hourStamp + _disablePeriod;

                // Create, validate, encode _updatedReleaseVal
                uint96 _updatedReleaseVal = WavDBC.cReleaseValEncoder6(
                    _startRelease,
                    _updatedEndRelease,
                    _preRelease,
                    _pausedAt
                );
                SContentTokenStorage.SContentToken storage SContentTokenStruct =
                SContentTokenStorage.sContentTokenStructStorage();
                SContentTokenStruct.releaseVal = _updatedReleaseVal;
            
                unchecked { ++i; }
                continue;
            }

        }

    }


    /**
     * @notice Allows a user to purchase music using ETH.
     * @param _buyer Address initiating execution.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Instances of the Content Token being purchased.
     */
    function wavSaleSingle(
        address _buyer,
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _purchaseQuantity
    ) external payable {
        ReturnValidation.returnIsAuthorizedAddr();

        _singleSaleReleaseValidation(_hashId);

        uint256 _hashPrice = WavDBC._validateDebitWavStore(_hashId, _numToken, _purchaseQuantity);
        
        if(_hashPrice > msg.value) {
            revert WavStore__InsufficientPayment();
        }

        uint256 _serviceFee = (_hashPrice * 100) / 1000;
        uint256 _creatorShare = _hashPrice - _serviceFee;

        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = CreatorProfitStorage.creatorProfitMapStructStorage();
        // (original) address wavId stuff originally went after here
        address _wavId = creatorProfitMapStruct.wavId;

        uint256 _netProfit  = WavDBC._allocateCollaboratorReserve(_hashId, _numToken, _creatorShare);

        creatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] += _netProfit;
        creatorProfitMapStruct.s_serviceBalance[_wavId][_serviceFee];

        WavAccess.wavAccess(
            _buyer,
            _hashId,
            _numToken,
            _purchaseQuantity
        );

        emit WavSaleSingle(msg.sender, _hashId, _numToken, _purchaseQuantity);
    } 


        


     /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorIdBatch Address batch of relevant publishers.
     * @param _hashIdBatch Batch of Content Token identifiers being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
     */
    function wavSaleBatch(
        address _buyer,
        address[] calldata _creatorIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint256[] calldata _purchaseQuantityBatch
    ) external payable {
        // Script & LOUT only
        ReturnValidation.returnIsAuthorized();

        uint256 _purchaseLength = _hashIdBatch.length;
        // All arrays must match
        if(
            _creatorIdBatch.length != _purchaseLength ||
            _numTokenBatch.length != _purchaseLength ||
            _purchaseQuantityBatch.length != _purchaseLength
        ) {
            revert WavStore__LengthMismatch();
        }

        // Pre-Release window validation
        _batchSaleReleaseValidation(_hashIdBatch);

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _weiPrices = WavDBC._validateDebitWavStoreBatch(
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );
      

        // Sum total Wei required
        uint256 _totalWei;
        for(uint256 i = 0; i < _purchaseLength;) {
            _totalWei += _weiPrices[i] * uint256(_purchaseQuantityBatch[i]);
            unchecked { ++i; }
        }
        if(_totalWei > msg.value) {
            revert WavStore__InsufficientPayment();
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = 
        CreatorProfitStorage.creatorProfitMapStructStorage();
        address _wavId = creatorProfitMapStruct.wavId;

        for(uint256 i = 0 i < _purchaseLength;) {
            uint256 _amountWei = _weiPrices[i] * uint256(_purchaseQuantityBatch[i]);
            address _creator = _creatorIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            
            uint256 _netCreator = WavDBC._allocateCollaboratorReserve(_hashId, _numTokenBatch[i], _creatorShare);

            creatorProfitMapStruct.s_ethEarnings[_creator][_hashId] += (_amountWei * 900) / 1000;
            creatorProfitMapStruct.s_serviceBalance[_wavId] += _serviceFee;
            unchecked { ++i; }
        }

        // Update Token Access (batch version to be created)
        WavAccess.wavAccessBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );

        emit WavSaleBatch(
        _buyer,
        _hashIdBatch,
        _numTokenBatch,
        _purchaseQuantityBatch
    );
    
    }

     /* uint256[] memory _usdPrices = WavDBC.validateAssetTokenPriceBatch(
            _hashIdBatch,
            _numTokenBatch
        );
        uint256[] memory _weiPrices = WavFeed.usdToWeiBatch(_usdPrices); */
    

   
    /* NEW NOTETOSELF: Ideally ownership index should be returned through entirely enforced means
    Otherwise we are putting MUCH faith on 'returnIsAuthorized' 
    
    NEW NoteToSelf Ensure we did that (been a min) and delete these comments, lol*/

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Instances of the Content Token being purchased.
     */
    function preReleasePurchaseSingle(
        address _buyer,
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _purchaseQuantity
    ) external payable {
        ReturnValidation.returnIsAuthorized();
        _preReleaseValidation(_hashId);
        // Similar to 'validateContentTokenRelease' we have to figure out if is 'sPriceUsd' or 'cPriceUsd'
        // If is 'sPriceUsd' we then have to determine price from stored numerical bitmap index
        // Determines value of Gets stored property value, decodes numToken price, returns
       
       /* uint256 _hashPrice = WavDBC.validateContentTokenPriceVal(_hashId, _numToken);

        _hashPrice = WavFeed.usdToWei(_hashPrice); */

        uint256 _hashPrice = WavDBC._validateDebitPreRelease(_hashId, _numToken, _purchaseQuantity);
        
        if(_hashPrice > msg.value) {
            revert WavStore__InsufficientPayment();
        }

        uint256 _serviceFee = (_hashPrice * 100) / 1000;
        uint256 _creatorShare = _hashPrice - _serviceFee;
        
        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = CreatorProfitStorage.creatorProfitMapStructStorage();

        // (original) address wavId stuff originally went after here
        address _wavId = creatorProfitMapStruct.wavId;

        uint256 _netProfit  = WavDBC._allocateCollaboratorReserve(_hashId, _numToken, _creatorShare);

        creatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] += _netProfit;
        creatorProfitMapStruct.s_serviceBalance[_wavId][_serviceFee];

        WavAccess.wavAccess(
            _buyer,
            _hashId,
            _numToken
            _purchaseQuantity,
        );
       // uint256 _ownershipIndex = ReturnMapping.returnOwnershipIndex(_buyer);
        // Emit an event for the purchase
        emit PreReleaseSale(msg.sender, _hashId, _numToken, _purchaseQuantity);
    }

    /*  // transfer msg.value directly from payable address(buyer) to Wav and address(_creatorId).
        // Payment as a result of collaborator payout should possibly be handled in a dedicted internal function.
        // CreatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] += msg.value; // or _hashPrice?
        // Relook upon WavAccess in context of this function, possibly break up some of the data retrieval into helper function(s).
        address wavId = creatorProfitMapStruct.wavId;
        creatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] +=
            (msg.value * 900) /
            1000;
        creatorProfitMapStruct.serviceProfit +=
            (msg.value * 100) /
            1000; */

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorIdBatch Address batch of relevant publishers.
     * @param _hashIdBatch Batch of Content Token identifiers being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
     */
    function preReleasePurchaseBatch(
        address _buyer,
        address[] calldata _creatorIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint256[] calldata _purchaseQuantityBatch
    ) external payable {
        // Script & LOUT only
        ReturnValidation.returnIsAuthorized();
        uint256 _purchaseLength = _hashIdBatch.length;
        
        // All arrays must match
        if(
            _creatorIdBatch.length != _purchaseLength ||
            _numTokenBatch.length != _purchaseLength ||
            _purchaseQuantityBatch.length != _purchaseLength
        ) {
            revert WavStore__LengthMismatch();
        }
        // Pre-Release window validation
        _preReleaseValidationBatch(_hashIdBatch);

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _weiPrices = WavDBC._validateDebitWavStoreBatch(
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );

        // Sum total Wei required
        uint256 _totalWei;
        for(uint256 i = 0; i < _purchaseLength;) {
            _totalWei += weiPrices[i] * _purchaseQuantityBatch[i];
            unchecked { ++i; }
        }
        
        if(_totalWei > msg.value) {
            revert WavStore__InsufficientPayment();
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = 
        CreatorProfitStorage.creatorProfitMapStructStorage();
        address _wavId = creatorProfitMapStruct.wavId;

        for(uint256 i = 0 i < _purchaseLength;) {
            uint256 _amountWei = _weiPrices[i] * uint256(_purchaseQuantityBatch[i]);
            address _creator = _creatorIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            
            uint256 _netCreator = WavDBC._allocateCollaboratorReserve(_hashId, _numTokenBatch[i], _creatorShare);

            creatorProfitMapStruct.s_ethEarnings[_creator][_hashId] += (_amountWei * 900) / 1000;
            creatorProfitMapStruct.s_serviceBalance[_wavId] += _serviceFee;
            unchecked { ++i; }
        }

        // Update Token Access (batch version to be created)
        WavAccess.wavAccessBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );

        emit PreReleaseBatch(
        _buyer,
        _hashIdBatch,
        _numTokenBatch,
        _purchaseQuantityBatch
    );
    }

    /*  // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _usdPrices = WavDBC.validateAssetTokenPriceBatch(
            _hashIdBatch,
            _numTokenBatch
        );
        uint256[] memory _weiPrices = WavFeed.usdToWeiBatch(_usdPrices); */


    /**
    * @notice Validates _hashId input to ensure valid standard sale state.
    * @dev Authenticates provided _hashId before completion of standard sale purchase logic.
    *      Function Selector: 0x022a8b81
    * @param _hashId Identifier of Content Token being queried.
    */
    function _singleSaleReleaseValidation(bytes32 _hashId) internal view {
        // Returns and decodes all values contained in releaseVal associated to hashId input
        (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) = 
        WavDBC.validateContentTokenReleaseData(_hashId);
        
        // Returns current hourStamp
        uint96 _hourStamp = WavDBC.currentHourStamp();
        
        // Ensures current hourStamp is not greater than non-zero endRelease
        if(_endRelease > 0 && _endRelease < _hourStamp) {
            revert WavStore__InvalidSale();
        }
        // Reverts if current hourStamp is greater than or equal to startRelease (preSale ended),
        // less than preRelease (preRelease hasn't started yet), or pausedAt non-zero (active pause)
        if(
            _hourStamp < _startRelease ||
            _hourStamp <= _preRelease || 
            _pausedAt > 0) {
            revert WavStore__InvalidSale();
        }
    }

    
    /**
    * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
    * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
    *      Function Selector: 0x637f234b
    * @param _hashIdBatch Batch of Content Token identifier values being queried.
    */
    function _batchSaleReleaseValidation(bytes32[] calldata _hashIdBatch) internal view {
        uint256 _hashLength = _hashIdBatch.length;
        uint96 _hourStamp = WavDBC.currentHourStamp();

        for(uint256 i = 0; i < _hashLength;) {
            bytes32 _hashId = _hashIdBatch[i];
            
            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            uint96 _packed = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
            if(_packed == 0) {
                _packed = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
                if(_packed == 0) {
                    revert WavStore__InputError404();
                }
            }
            // Decode into individual fields
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_packed);
            
            // Validate time window & pausedAt
            if(_endRelease > 0 && _endRelease < _hourStamp) {
                revert WavStore__PreSaleNotFound();
            }
            // Must be after _startRelease, after _preRelease
            if(
                _hourStamp < _startRelease ||
                _hourStamp <= _preRelease ||
                _pausedAt > 0
            ) {
                revert WavStore__PreSaleNotFound();
            }

            unchecked { ++i; }
        
        }
    }


    // check current hrStamp
    // Publication process should ensure _preRelease < _startRelease, 
    //_pausedAt value has not disabled sale, 
    //_endRelease is either zero or less than current timestamp
    /**
    * @notice Validates _hashId input to ensure valid preSale state.
    * @dev Authenticates provided _hashId before completion of preSale purchase logic.
    *      Function Selector: 0x64bbbc2f
    * @param _hashId Identifier of Content Token being queried.
    */
    function _preReleaseValidation(bytes32 _hashId) internal view {
        // Returns and decodes all values contained in releaseVal associated to hashId input
        (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) = 
        WavDBC.validateContentTokenReleaseData(_hashId);
        
        // Returns current hourStamp
        uint96 _hourStamp = WavDBC.currentHourStamp();
        
        // Ensures current hourStamp is not greater than non-zero endRelease
        if(_endRelease > 0 && _endRelease < _hourStamp) {
            revert WavStore__InvalidSale();
        }
        // Reverts if current hourStamp is greater than or equal to startRelease (preSale ended),
        // less than preRelease (preRelease hasn't started yet), or pausedAt non-zero (active pause)
        if(
            _hourStamp >= _startRelease ||
            _hourStamp < _preRelease || 
            _pausedAt > 0) {
            revert WavStore__InvalidSale();
        }
    }


        /**
        * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
        * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
        *      Function Selector: 0x9b23bdf0
        * @param _hashIdBatch Batch of Content Token identifier values being queried.
        */
    function _preReleaseValidationBatch(bytes32[] calldata _hashIdBatch) internal view {
        uint256 _hashLength = _hashIdBatch.length;
        uint96 _currentHourStamp = WavDBC.currentHourStamp();

        for(uint256 i = 0; i < _hashLength;) {
            bytes32 _hashId = _hashIdBatch[i];
            
            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            uint96 _packed = ReturnMapping.returnSContentTokenReleaseVal(_hashId);
            if(_packed == 0) {
                _packed = ReturnMapping.returnCContentTokenReleaseVal(_hashId);
                if(_packed == 0) {
                    revert WavStore__InputError404();
                }
            }
            // Decode into individual fields
            (uint96 _startRelease, uint96 _endRelease, uint96 _preRelease, uint8 _pausedAt) =
            WavDBC.cReleaseValDecoder6(_packed);
            
            // Validate time window & pausedAt
            if(_endRelease > 0 && _endRelease < _currentHour) {
                revert WavStore__PreSaleNotFound();
            }
            // Must be before 'startRelease' (during active preSale window)
            if(
                _currentHour >= _startRelease ||
                _currentHour < _preRelease ||
                _pausedAt > 0
            ) {
                revert WavStore__PreSaleNotFound();
            }

            unchecked { ++i; }
        
        }
    }

    /**
     * @notice Withdraws earnings from the caller's balance.
     * @dev Ensures sufficient balance, updates and transfers value. Gasless checks and automated inputs preformed by front-end.
     * @param _creatorId The address of the creator.
     * @param _to The address to send the funds to.
     * @param _amount The amount to withdraw.
     */
    function withdrawEthEarnings(
        address _creatorId,
        address _to, // Address to send the funds to
        uint256 _amount // Amount to withdraw
    ) external {
        uint256 _earnings = returnEthEarnings(_creatorId, _hashId);
        // Ensure caller has enough balance
        if (_earnings < _amount) {
            revert WavStore__InsufficientEarnings();
        }
        CreatorProfitStorage.CreatorProfitMap
            storage creatorProfitMapStruct = CreatorProfitStorage
                .creatorProfitMapStructStorage();
        // Update caller's balance
        creatorProfitMapStruct.s_ethEarnings[msg.sender] -= _amount;
        // Transfer specified amount to _to
        payable(_to).transfer(_amount);
    }

    /**
     * @notice Handles core logic for purchase of resale content.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _seller The address of the seller.
     * @param _buyer The address initiating purchase of a Content Token.
     * @param _creatorId Address of original publisher of the Content Token.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Instances of the Content Token being purchased.
     * @param _priceInEth The price of the content in ETH.
     * @param _nonce A unique number to prevent replay attacks.
     * @param _signature The signature to verify the transaction.
     */
    function wavResaleSingle(
        address _seller,
        address _buyer,
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint256 _purchaseQuantity,
        uint256 _priceInEth,
        uint256 _nonce,
        bytes memory _signature
    ) external {
        ReturnValidation.returnIsAuthorizedAddr();

        // Ensure sufficient payment sent
        uint256 _valueRequired = _priceInEth * _purchaseQuantity;
        if(msg.value < _valueRequired) revert WavStore__InsufficientPayment();

        // Verify signature (front-end data signature)
        bytes32 _messageHash = keccak256(abi.encodePacked(_nonce, msg.sender, _priceInEth));
        address _signer = WavFortress.verifySignature(_messageHash, _signature);
        if (_signer != msg.sender) revert WavFortress__InvalidSignature();

        // Consume nonce (replay protection)
        WavFortress.checkUseUpdateNonce(_nonce);

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = 
        CreatorProfitStorage.creatorProfitMapStructStorage();
        address _wavId = creatorProfitMapStruct.wavId;

        uint256 _sellerShare = (_valueRequired * 900) / 1000;
        uint256 _creatorShare = (_valueRequired * 50) / 1000;
        uint256 _serviceFee = (_valueRequired * 50) / 1000;

        creatorProfitMapStruct.s_ethEarnings[_seller][_hashId] += _sellerShare
        creatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] += _creatorShare;
        creatorProfitMapStruct.s_serviceBalance[_wavId] += _serviceFee

        // Transfer ownership to buyer
        WavAccess.wavExchange(
            _buyer,
            _seller,
            _hashId,
            _numToken,
            _purchaseQuantity
        );

        // Emit an event for the resale
        emit WavResaleSingle(_buyer, _hashId, _numToken, _purchaseQuantity);
    }
     
     
    /*  WavAccess(s_WavAccess).wavAccess(
            _buyer,
            _seller,
            _hashId,
            _numToken,
            _purchaseQuantity
        ); 
       // Refund possible excess ETH
        if(msg.value > _valueRequired) {
            unchecked {
                payable(msg.sender).transfer(msg.value - _valueRequired);
            }
        }
    */

    /**
     * @notice Handles core logic for purchase of resale content.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _sellerBatch Batch of addresses selling Content Tokens.
     * @param _buyer The address initiating purchase of a Content Token.
     * @param _creatorIdBatch Address batch of relevant publishers.
     * @param _hashIdBatch Batch of Content Token identifiers being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Instances of the Content Token being purchased.
     * @param _priceInEthBatch Instances of each Content Token being purchased.
     * @param _nonce A unique number to prevent replay attacks.
     * @param _signature The signature to verify the transaction.
    */
    function wavResaleBatch(
        address[] calldata _sellerBatch,
        address _buyer,
        address[] calldata _creatorIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint256[] calldata _purchaseQuantityBatch,
        uint256[] calldata _priceInEthBatch,
        uint256 _nonce,
        bytes calldata _signature
    ) external {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;

        // basic length checks
        if(
            _sellerBatch.length != _hashLength ||
            _creatorIdBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _priceInEthBatch.length != _hashLength
        ) revert WavStore__LengthMismatch();

        // total required payment (price * qty)
        uint256 _valueRequired;
        for(uint256 i = 0; i < _hashLength;) {
            _valueRequired += _priceInEthBatch[i] * _purchaseQuantityBatch[i];
            unchecked { ++i; }
        }
        
        if(msg.value < _valueRequired) revert WavStore__InsufficientPayment();

        // verify signature (front-end data signature)
        bytes32 _messageHash = keccak256(abi.encodePacked(_nonce, msg.sender, _valueRequired));
        address _signer = WavFortress.verifySignature(_messageHash, _signature);
        if(_signer != msg.sender) revert WavStore__HashResultInvalid();

        // Consume nonce once for entire batch
        WavFortress.checkUseUpdateNonce(_nonce);

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitMap storage creatorProfitMapStruct = 
        CreatorProfitStorage.creatorProfitMapStructStorage();
        address _wavId = creatorProfitMapStruct.wavId;


        for(uint256 i = 0; i < _hashLength;) {
            uint256 _contentValue = _priceInEthBatch[i] * _purchaseQuantityBatch[i];
            address _seller = _sellerBatch[i];
            address _creatorId = _creatorIdBatch[i];
            bytes32 _hashId = hashIdBatch[i];

            uint256 _sellerShare = (_contentValue * 900) / 1000;
            uint256 _creatorShare = (_contentValue * 50) / 1000;
            uint256 _serviceFee = (_contentValue * 50) / 1000;

            creatorProfitMapStruct.s_ethEarnings[_seller][_hashId] += _sellerShare;
            creatorProfitMapStruct.s_ethEarnings[_creatorId][_hashId] += _creatorShare;
            creatorProfitMapStruct.serviceProfit += _serviceFee;

            unchecked { ++i; }

            
        }

        // Transfer ownership to buyer
        WavAccess.wavExchangeBatch(
            _buyer,
            _sellerBatch
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );

        emit WavResaleBatch(_buyer, _hashIdBatch, _numTokenBatch, _purchaseQuantityBatch);

    }

    /*    WavAccess(s_WavAccess).wavAccessBatch(
            _buyer,
            _sellerBatch
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        ); 
        
        if(msg.value > _valueRequired) { // make sure shouldn't be _buyer instead of msg.sender
            unchecked {
                payable(msg.sender).transfer(msg.value - totalRequired);
            }
        }
        */

    function generateResaleSplitBatch(
        bytes32 _hashId,
        uint256 _purchaseQuantity,
        uint256 _ethPrice
    )
        public
        pure
        returns (
            uint256 _sellerSplit,
            uint256 _creatorSplit,
            uint256 _collaboratorSplit,
            uint256 _serviceSplit
        )
    {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint256 collaboratorTotal = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .collaboratorVal
            .length;

        uint256 _total = _purchaseQuantity * _ethPrice;

        _sellerSplit = (_total * 900) / 1000;
        _creatorSplit = (_total * 50) / 1000;
        _collaboratorSplit = (_total * 25) / 1000;
        _serviceShare = (_total * 25) / 1000;
    }

    function generateResaleSplitSingle(
        uint256 _purchaseQuantity,
        uint256 _ethPrice,
        bytes32 _hashId
    )
        public
        pure
        returns (
            uint256 _sellerSplit,
            uint256 _creatorSplit,
            uint256 _collaboratorSplit,
            uint256 _serviceSplit
        )
    {
        uint256 _total = _purchaseQuantity * _ethPrice;

        if(s_collaborators[_hashId] >= 1) {
            for(s_collaborators[_hashId].addressVal)
        }

        _sellerSplit = (_total * 900) / 1000;
        _creatorSplit = (_total * 75) / 1000;
        _serviceShare = (_total * 25) / 1000;
    }

    /**
     * @notice Validates sufficient remaining supply relative to a purchase quantity.
     * @dev Should always be called before final execution of an asset purchase.
     * @param _hashId of the asset being validated.
     * @param _purchaseQuantity of instances to be purchased.
     * @return _tokenSupplyRemainder
     */
    function validatePurchaseQuantity(
        bytes32 _hashId,
        uint256 _purchaseQuantity
    ) external view returns (uint256 _tokenSupplyRemainder) {
        uint256 _remainder = returnRemainingSupply(_hashId);
        if (_remainder < _purchaseQuantity) {
            revert WavStore__InsufficientTokenSupply();
        }
        _tokenSupplyRemainder = (_remainder - _purchaseQuantity);
        return _tokenSupplyRemainder;
          

    }
}



