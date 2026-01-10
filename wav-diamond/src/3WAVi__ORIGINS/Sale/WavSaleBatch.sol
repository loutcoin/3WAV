// SPDX-License-Identifier: UNLICENSED
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
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/ValidateSupply/ValidateWavSaleBatch.sol";

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
    event WavSaleBatchIndex(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint256 _purchaseQuantity
    );

    event WavSaleBatchQuantity(
        address indexed _buyer,
        uint256 indexed _contentCount
    );

    error WavSaleBatch__InsufficientPayment();
    error WavSaleBatch__InvalidSale();
    error WavSaleBatch__ExpiredSale();

    /**
     * @notice Validates dynamic quantities of _hashId inputs to ensure valid preSale states.
     * @dev Authenticates provided _hashIdBatch before completion of preSale purchase logic.
     * @param _wavSaleToken Batch of user-defined WavSale structs.
     */
    function _batchSaleReleaseValidation(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal view {
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        for (uint256 i = 0; i < _wavSaleToken.length; ) {
            bytes32 _hashId = _wavSaleToken[i].hashId;

            // Validates timestamp in relation to sale
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
        LibAccessBatch._wavAccessBatch(_buyer, _wavSaleToken);
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

        {
            //_batchSaleReleaseValidation(_hashIdBatch);
            _batchSaleReleaseValidation(_wavSaleToken);
        }

        // Batch price lookup (in USD, 6-decimals)
        uint256[] memory _weiPrices = ValidateWavSaleBatch
            ._validateDebitWavStoreBatch(_wavSaleToken);

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
            _creatorShare = LibCollaboratorReserve._collaboratorReserveRouter(
                _hashId,
                _wavSaleToken[i].numToken,
                _creatorShare
            );

            CreatorProfitStructStorage.s_ethEarnings[_creator][
                _hashId
            ] += _creatorShare;
            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;
            emit WavSaleBatchIndex(
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
            // Update Token Access
            LibAccessBatch._wavAccessBatch(_buyer, _wavSaleToken);
        }

        emit WavSaleBatchQuantity(_buyer, _wavSaleToken.length);
    }
}
