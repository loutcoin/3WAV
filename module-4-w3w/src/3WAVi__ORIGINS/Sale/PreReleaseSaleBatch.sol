// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

import {
    CreatorProfitStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";

import {
    ValidatePreReleaseSaleBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/ValidatePreReleaseSaleBatch.sol";

import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";

import {
    LibAccessBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibAccessBatch.sol";

import {ReleaseDBC} from "../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract PreReleaseSaleBatch {
    event PreReleaseSaleBatchIndex(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint256 _purchaseQuantity
    );

    event PreReleaseSaleBatchQuantity(
        address indexed _buyer,
        uint256 indexed _contentCount
    );

    error PreReleaseSaleBatch__InsufficientPayment();
    error PreReleaseSaleBatch__InputError404();
    error PreReleaseSaleBatch__ExpiredSale();
    error PreReleaseSaleBatch__InvalidSale();

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function preReleasePurchaseBatch(
        address _buyer,
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) external payable {
        // Script & LOUT only
        ReturnValidation.returnIsAuthorized();

        {
            // Pre-Release window validation ***** change back to original name after done, do not forget *****
            _preReleaseValidationBatch(_wavSaleToken);
        }

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _weiPrices = ValidatePreReleaseSaleBatch
            ._validateDebitPreReleaseBatch(_wavSaleToken);

        // Sum total Wei required
        uint256 _totalWei; // _wavSaleToken.length;
        for (uint256 i = 0; i < _weiPrices.length; ) {
            // likely needs to be typecasted (_purchaseQuantity to type uint256)
            _totalWei += _weiPrices[i] * _wavSaleToken[i].purchaseQuantity;
            unchecked {
                ++i;
            }
        }

        if (_totalWei > msg.value) {
            revert PreReleaseSaleBatch__InsufficientPayment();
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;
        //_wavSaleToken.length;
        for (uint256 i = 0; i < _weiPrices.length; ) {
            uint256 _amountWei = _weiPrices[i] *
                uint256(_wavSaleToken[i].purchaseQuantity);
            address _creator = _wavSaleToken[i].creatorId;
            bytes32 _hashId = _wavSaleToken[i].hashId;

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            // Routes to correct location whether SContentToken || CContentToken
            _creatorShare = LibCollaboratorReserve._collaboratorReserveRouter(
                _hashId,
                _wavSaleToken[i].numToken,
                _creatorShare
            );

            CreatorProfitStructStorage.s_ethEarnings[_creator][
                _hashId
            ] += _creatorShare;

            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;

            emit PreReleaseSaleBatchIndex(
                _buyer,
                _hashId,
                _wavSaleToken[i].numToken,
                i
            );

            unchecked {
                ++i;
            }
        }

        {
            // Update _buyer ContentToken Access
            LibAccessBatch._wavAccessBatch(_buyer, _wavSaleToken);
        }

        emit PreReleaseSaleBatchQuantity(_buyer, _wavSaleToken.length);
    }

    /**
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _preReleaseValidationBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal view {
        uint96 _currentHourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            uint96 _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            if (_releaseVal != 0) {
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                // Validate time window & pausedAt
                if (_endRelease > 0 && _endRelease < _currentHourStamp) {
                    revert PreReleaseSaleBatch__ExpiredSale();
                }
                // Must be before 'startRelease' (during active preSale window)
                if (
                    _currentHourStamp >= _startRelease ||
                    _currentHourStamp < _preRelease ||
                    _pausedAt > 0
                ) {
                    revert PreReleaseSaleBatch__InvalidSale();
                }
                unchecked {
                    ++i;
                }
            } else if (_releaseVal == 0) {
                uint96 _releaseVal = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal;

                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                // Validate time window & pausedAt
                if (_endRelease > 0 && _endRelease < _currentHourStamp) {
                    revert PreReleaseSaleBatch__ExpiredSale();
                }
                // Must be before 'startRelease' (during active preSale window)
                if (
                    _currentHourStamp >= _startRelease ||
                    _currentHourStamp < _preRelease ||
                    _pausedAt > 0
                ) {
                    revert PreReleaseSaleBatch__InvalidSale();
                }
                unchecked {
                    ++i;
                }
            } else {
                revert PreReleaseSaleBatch__InputError404();
            }
        }
    }
}
