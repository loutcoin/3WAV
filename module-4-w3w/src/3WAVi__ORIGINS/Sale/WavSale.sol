// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";

import {
    LibAccess
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibAccess.sol";

import {
    ValidateWavSale
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/ValidateSupply/ValidateWavSale.sol";

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
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract WavSale {
    event WavSaleSingle(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _purchaseQuantity
    );

    error WavSale__InsufficientPayment();
    error WavSale__InvalidSale();
    error WavSale__ExpiredSale();

    /**
     * @notice Validates _hashId input to ensure valid preSale states.
     * @dev Authenticates provided _hashId before completion of preSale purchase logic.
     * @param _hashId Identifier of Content Token being queried.
     */
    function _singleSaleReleaseValidation(bytes32 _hashId) internal view {
        // Returns and decodes all values contained in releaseVal associated to hashId input
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
            revert WavSale__ExpiredSale();
        }
        // Reverts if current hourStamp is less than startRelease (is not yet available for sale),
        // less than or equal to preRelease
        if (
            _hourStamp < _startRelease ||
            _hourStamp <= _preRelease ||
            _pausedAt > 0
        ) {
            revert WavSale__InvalidSale();
        }
    }

    /**
     * @notice Allows a user to purchase content using ETH.
     * @param _buyer Address initiating execution.
     * @param _wavSaleToken User-defined WavSale struct.
     */
    function wavSaleSingle(
        address _buyer,
        WavSaleToken.WavSale calldata _wavSaleToken
    ) external payable {
        ReturnValidation.returnIsAuthorized();

        {
            _singleSaleReleaseValidation(_wavSaleToken.hashId);
        }

        uint256 _hashPrice = ValidateWavSale._validateDebitWavStore(
            _wavSaleToken
        );

        if (_hashPrice > msg.value) {
            revert WavSale__InsufficientPayment();
        }

        uint256 _serviceFee = (_hashPrice * 100) / 1000;
        uint256 _creatorShare = _hashPrice - _serviceFee;

        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();

        address _wavId = CreatorProfitStructStorage.wavId;

        _creatorShare = LibCollaboratorReserve._collaboratorReserveRouter(
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _creatorShare
        );

        CreatorProfitStructStorage.s_ethEarnings[_wavSaleToken.creatorId][
            _wavSaleToken.hashId
        ] += _creatorShare;
        CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;

        {
            LibAccess._wavAccess(_buyer, _wavSaleToken);
        }

        emit WavSaleSingle(
            _buyer,
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _wavSaleToken.purchaseQuantity
        );
    }

    /**
     * @notice Grants Content Token access during sale conducted through official service channels
     * @dev This function is used to grant access to content purchased via non-human service channels.
     * @param _buyer The address of the buyer.
     * @param _wavSaleToken User-defined WavSale struct.
     */
    function wavAccess(
        address _buyer,
        WavSaleToken.WavSale calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized();
        LibAccess._wavAccess(_buyer, _wavSaleToken);
    }
}
