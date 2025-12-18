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
    event WhatIsHash(bytes32 indexed _hashId);

    event SReleaseProp(uint96 _releaseVal);

    event CReleaseProp(uint96 _releaseVal);

    event PreReleaseBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint112[] _purchaseQuantity
    );

    event ReleaseProperties(
        uint96 _startRelease,
        uint96 _endRelease,
        uint96 _preRelease,
        uint8 _pausedAt
    );

    error PreReleaseSaleBatch__LengthMismatch();
    error PreReleaseSaleBatch__InsufficientPayment();
    error PreReleaseSaleBatch__InputError404();
    error PreReleaseSaleBatch__ExpiredSale();
    error PreReleaseSaleBatch__InvalidSale();

    /*
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorIdBatch Address batch of relevant publishers.
     * @param _hashIdBatch Batch of Content Token identifiers being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Instances of each Content Token being purchased.
     */
    /*function preReleasePurchaseBatch(
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
            revert PreReleaseSaleBatch__LengthMismatch();
        }
        // Pre-Release window validation
        _preReleaseValidationBatch(_hashIdBatch);

        // Batch price lookup (in USD, 6-decimals),
        // Conversion to Wei
        uint256[] memory _weiPrices = ValidatePreReleaseSaleBatch
            ._validateDebitPreReleaseBatch(
                _hashIdBatch,
                _numTokenBatch,
                _purchaseQuantityBatch
            );

        // Sum total Wei required
        uint256 _totalWei;
        for (uint256 i = 0; i < _purchaseLength; ) {
            _totalWei += _weiPrices[i] * _purchaseQuantityBatch[i];
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

        for (uint256 i = 0; i < _purchaseLength; ) {
            uint256 _amountWei = _weiPrices[i] *
                uint256(_purchaseQuantityBatch[i]);
            address _creator = _creatorIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];

            uint256 _serviceFee = (_amountWei * 100) / 1000;
            uint256 _creatorShare = _amountWei - _serviceFee;

            uint256 _netCreator = LibCollaboratorReserve
                ._allocateCollaboratorReserve(
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

        emit PreReleaseBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );
    }*/

    /*
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector: 0x9b23bdf0
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     */
    /*function _preReleaseValidationBatch(
        bytes32[] calldata _hashIdBatch
    ) internal view {
        uint256 _hashLength = _hashIdBatch.length;
        uint96 _currentHourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            uint96 _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;
            if (_releaseVal == 0) {
                uint96 _releaseVal = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal;
                if (_releaseVal == 0) {
                    revert PreReleaseSaleBatch__InputError404();
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
            if (_endRelease > 0 && _endRelease < _currentHourStamp) {
                revert PreReleaseSaleBatch__PreSaleNotFound();
            }
            // Must be before 'startRelease' (during active preSale window)
            if (
                _currentHourStamp >= _startRelease ||
                _currentHourStamp < _preRelease ||
                _pausedAt > 0
            ) {
                revert PreReleaseSaleBatch__PreSaleNotFound();
            }

            unchecked {
                ++i;
            }
        }
    }*/

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
            ._validateDebitPreReleaseBatch2(_wavSaleToken);

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
            LibCollaboratorReserve._collaboratorReserveRouter(
                _hashId,
                _wavSaleToken[i].numToken,
                _creatorShare
            );

            // uint256 _netCreator = LibCollaboratorReserve

            CreatorProfitStructStorage.s_ethEarnings[_creator][_hashId] +=
                (_amountWei * 900) /
                1000;
            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;
            unchecked {
                ++i;
            }
        }

        // Update Token Access (batch version to be created)
        {
            LibAccessBatch._wavAccessBatch2(_buyer, _wavSaleToken);
        }

        /*emit PreReleaseBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );*/
    }

    /**
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector:
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _preReleaseValidationBatch2(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal {
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
            if (_releaseVal == 0) {
                uint96 _releaseVal = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashId]
                    .cReleaseVal;
                if (_releaseVal == 0) {
                    revert PreReleaseSaleBatch__InputError404();
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
        }
    }

    /**
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     *      Function Selector:
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _preReleaseValidationBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal {
        uint96 _currentHourStamp = ReturnValidation._returnHourStamp();

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;
            emit WhatIsHash(_hashId);

            // Fetch the "packed" releaseData (handles cContentToken & sContentToken under the hood)
            uint96 _releaseVal = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .releaseVal;

            emit SReleaseProp(_releaseVal);

            if (_releaseVal != 0) {
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                emit ReleaseProperties(
                    _startRelease,
                    _endRelease,
                    _preRelease,
                    _pausedAt
                );

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

                emit CReleaseProp(_releaseVal);
                (
                    uint96 _startRelease,
                    uint96 _endRelease,
                    uint96 _preRelease,
                    uint8 _pausedAt
                ) = ReleaseDBC._cReleaseValDecoder6(_releaseVal);

                emit ReleaseProperties(
                    _startRelease,
                    _endRelease,
                    _preRelease,
                    _pausedAt
                );

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
