// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";
import {
    LibAccessBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibAccessBatch.sol";
import {
    ValidateWavSaleBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/ValidateWavSaleBatch.sol";

import {ReleaseDBC} from "../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";
import {
    CreatorProfitStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";
import {
    CreatorTokenMapStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {
    TokenBalanceStorage
} from "../../../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";
import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract WavSaleBatch {
    /*event WavSaleBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint112[] _purchaseQuantity
    );*/
    event test100(bool success);

    error WavSaleBatch__InsufficientPayment();
    error WavSaleBatch__InvalidSale();
    error WavSaleBatch__ExpiredSale();
    /*
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorIdBatch Address batch of relevant publishers.
     * @param _hashIdBatch Batch of Content Token identifiers being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
     */
    /*function wavSaleBatch(
        address _buyer,
        address[] calldata _creatorIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _purchaseQuantityBatch
    ) external payable {
        // Script & LOUT only
        ReturnValidation.returnIsAuthorized();

        uint256 _purchaseLength = _hashIdBatch.length;
        // All arrays must match
        if (
            _creatorIdBatch.length != _purchaseLength ||
            _numTokenBatch.length != _purchaseLength ||
            _purchaseQuantityBatch.length != _purchaseLength
        ) {
            revert WavSale__LengthMismatch();
        }

        // Pre-Release window validation
        _batchSaleReleaseValidation(_hashIdBatch);

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _weiPrices = ValidateWavSaleBatch
            ._validateDebitWavStoreBatch(
                _hashIdBatch,
                _numTokenBatch,
                _purchaseQuantityBatch
            );

        // Sum total Wei required
        uint256 _totalWei;
        for (uint256 i = 0; i < _purchaseLength; ) {
            _totalWei += _weiPrices[i] * uint256(_purchaseQuantityBatch[i]);
            unchecked {
                ++i;
            }
        }
        if (_totalWei > msg.value) {
            revert WavSale__InsufficientPayment();
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        for (uint256 i = 0; i < _purchaseLength; ) {
            uint256 _amountWei = _weiPrices[i] *
                uint256(_purchaseQuantityBatch[i]);
            address _creator = _creatorIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            // Routes to correct location whether SContentToken || CContentToken
            uint256 _netCreator = LibCollaboratorReserve
                ._collaboratorReserveRouter(
                    _hashId,
                    _numTokenBatch[i],
                    _creatorShare
                );

            CreatorProfitStructStorage.s_ethEarnings[_creator][_hashId] +=
                (_amountWei * 900) /
                1000;
            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;
            unchecked {
                ++i;
            }
        }

        // Update Token Access (batch version to be created)
        LibAccessBatch._wavAccessBatch(
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
    }*/

    /*
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector: 0x637f234b
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     */
    /*function _batchSaleReleaseValidation(
        bytes32[] calldata _hashIdBatch
    ) internal view {
        uint256 _hashLength = _hashIdBatch.length;
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            /*uint96 _packed = ReturnMapping.returnSContentTokenReleaseVal(
                _hashId
            );*/
    /*uint96 _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;
            if (_releaseVal == 0) {
                uint96 _releaseVal = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal;
                if (_releaseVal == 0) {
                    revert WavSale__InputError404();
                }
            }
            // Decode into individual fields
            (
                uint96 _startRelease,
                uint96 _endRelease,
                uint96 _preRelease,
                uint8 _pausedAt
            ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

            // Validate time window & pausedAt
            if (_endRelease > 0 && _endRelease < _hourStamp) {
                revert WavSale__InvalidSale();
            }
            // Must be after _startRelease, after _preRelease
            if (
                _hourStamp < _startRelease ||
                _hourStamp <= _preRelease ||
                _pausedAt > 0
            ) {
                revert WavSale__InvalidSale();
            }

            unchecked {
                ++i;
            }
        }
    }*/

    /*
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector:
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    /*function _batchSaleReleaseValidation(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal view {
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            /*uint96 _packed = ReturnMapping.returnSContentTokenReleaseVal(
                _hashId
            );*/
    /*uint96 _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;
            if (_releaseVal == 0) {
                uint96 _releaseVal = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal;
                if (_releaseVal == 0) {
                    revert WavSale__InputError404();
                }
            }
            // Decode into individual fields
            (
                uint96 _startRelease,
                uint96 _endRelease,
                uint96 _preRelease,
                uint8 _pausedAt
            ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

            // Validate time window & pausedAt
            if (_endRelease > 0 && _endRelease < _hourStamp) {
                revert WavSale__InvalidSale();
            }
            // Must be after _startRelease, after _preRelease
            if (
                _hourStamp < _startRelease ||
                _hourStamp <= _preRelease ||
                _pausedAt > 0
            ) {
                revert WavSale__InvalidSale();
            }

            unchecked {
                ++i;
            }
        }
    }*/

    /**
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector:
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _batchSaleReleaseValidation(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal view {
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            /*uint96 _packed = ReturnMapping.returnSContentTokenReleaseVal(
                _hashId
            );*/
            (
                uint96 _startRelease,
                uint96 _endRelease,
                uint96 _preRelease,
                uint8 _pausedAt
            ) = ReleaseDBC.validateContentTokenReleaseData(_hashId);

            // Returns current hourStamp
            uint96 _hourStamp = ReturnValidation._returnHourStamp();

            // Ensures current hourStamp is not greater than non-zero endRelease
            if (_endRelease > 0 && _endRelease < _hourStamp) {
                revert WavSaleBatch__ExpiredSale();
            }
            // Reverts if current hourStamp is less than startRelease (is not yet available for sale),
            // less than or equal to preRelease
            if (
                _hourStamp < _startRelease ||
                _hourStamp <= _preRelease ||
                _pausedAt > 0
            ) {
                revert WavSaleBatch__InvalidSale();
            }

            unchecked {
                ++i;
            }
        }
    }

    /*
     * @notice Grants batch Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Total instances of each numToken being debited.
     */
    /*function wavAccessBatch(
        address _buyer,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _purchaseQuantityBatch
    ) external {
        ReturnValidation.returnIsAuthorized();
        LibAccessBatch._wavAccessBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );
    }*/

    /**
     * @notice Grants batch Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function wavAccessBatch(
        address _buyer,
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized();
        LibAccessBatch._wavAccessBatch2(_buyer, _wavSaleToken);
    }

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _wavSaleToken User-defined batch of WavSale structs.
     */
    function wavSaleBatch(
        address _buyer,
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) external payable {
        // Script & LOUT only
        ReturnValidation.returnIsAuthorized();

        // All arrays must match
        /*if (
            _creatorIdBatch.length != _purchaseLength ||
            _numTokenBatch.length != _purchaseLength ||
            _purchaseQuantityBatch.length != _purchaseLength
        ) {
            revert WavSale__LengthMismatch();
        }*/

        // Pre-Release window validation
        // Needs to accept _wavSaleToken
        //

        {
            //_batchSaleReleaseValidation(_hashIdBatch);
            _batchSaleReleaseValidation(_wavSaleToken);
        }

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        // Needs to accept _wavSaleToken
        /*uint256[] memory _weiPrices = ValidateWavSaleBatch
            ._validateDebitWavStoreBatch(
                _hashIdBatch,
                _numTokenBatch,
                _purchaseQuantityBatch
            );*/

        uint256[] memory _weiPrices = ValidateWavSaleBatch
            ._validateDebitWavStoreBatch(_wavSaleToken);

        emit test100(true);

        // Sum total Wei required
        uint256 _totalWei;
        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            //_totalWei += _weiPrices[i] * uint256(_purchaseQuantityBatch[i]);
            _totalWei +=
                _weiPrices[i] *
                uint256(_wavSaleToken[i].purchaseQuantity);
            unchecked {
                ++i;
            }
        }
        if (_totalWei > msg.value) {
            revert WavSaleBatch__InsufficientPayment();
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            uint256 _amountWei = _weiPrices[i] *
                uint256(_wavSaleToken[i].purchaseQuantity);
            address _creator = _wavSaleToken[i].creatorId;
            bytes32 _hashId = _wavSaleToken[i].hashId;

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            // Routes to correct location whether SContentToken || CContentToken
            LibCollaboratorReserve._collaboratorReserveRouter(
                _hashId,
                _wavSaleToken[i].numToken,
                _creatorShare
            );
            // uint256 _netCreator = LibCollaboratorReserve

            // should maybe be _netProfit
            CreatorProfitStructStorage.s_ethEarnings[_creator][_hashId] +=
                (_amountWei * 900) /
                1000;
            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;
            unchecked {
                ++i;
            }
        }

        // Update Token Access
        /*LibAccessBatch._wavAccessBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );*/
        {
            LibAccessBatch._wavAccessBatch2(_buyer, _wavSaleToken);
        }

        /*emit WavSaleBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );*/
    }
}
