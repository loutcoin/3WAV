// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";
import {
    CreatorProfitStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";
import {
    ValidatePreReleaseSale
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/ValidatePreReleaseSale.sol";
import {
    LibCollaboratorReserve
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibCollaboratorReserve.sol";
import {
    LibAccess
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibAccess.sol";
import {ReleaseDBC} from "../../../src/3WAVi__Helpers/DBC/ReleaseDBC.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract PreReleaseSale {
    event TestHourStamp(uint96 indexed _hourStamp);
    event ThatFunctionWorks(bool _success);
    event TestTimeValues(
        uint96 indexed _startRelease,
        uint96 indexed _endRelease,
        uint96 indexed _preRelease,
        uint8 _pausedAt
    );

    event PreReleaseSale(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _purchaseQuantity
    );

    error PreReleaseSale__InsufficientPayment();
    error PreReleaseSale__ExpiredSale();
    error PreReleaseSale__InvalidSale();
    /*
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _creatorId The address of the creator.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Instances of the Content Token being purchased.
     */
    /*function preReleasePurchaseSingle(
        address _buyer,
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _purchaseQuantity
    ) external payable {
        ReturnValidation.returnIsAuthorized();
        _preReleaseValidation(_hashId);
        // Similar to 'validateContentTokenRelease' we have to figure out if is 'sPriceUsd' or 'cPriceUsd'
        // If is 'sPriceUsd' we then have to determine price from stored numerical bitmap index
        // Determines value of Gets stored property value, decodes numToken price, returns

        /* uint256 _hashPrice = WavDBC.validateContentTokenPriceVal(_hashId, _numToken);

        _hashPrice = WavFeed.usdToWei(_hashPrice); */

    /*uint256 _hashPrice = ValidatePreReleaseSale._validateDebitPreRelease(
            _hashId,
            _numToken,
            _purchaseQuantity
        );

        if (_hashPrice > msg.value) {
            revert PreReleaseSale__InsufficientPayment();
        }

        uint256 _serviceFee = (_hashPrice * 100) / 1000;
        uint256 _creatorShare = _hashPrice - _serviceFee;

        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();

        // (original) address wavId stuff originally went after here
        address _wavId = CreatorProfitStructStorage.wavId;

        uint256 _netProfit = LibCollaboratorReserve
            ._allocateCollaboratorReserve(_hashId, _numToken, _creatorShare);

        CreatorProfitStructStorage.s_ethEarnings[_creatorId][
            _hashId
        ] += _netProfit;
        CreatorProfitStructStorage.s_serviceBalance[_wavId] = _serviceFee;

        LibAccess._wavAccess(_buyer, _hashId, _numToken, _purchaseQuantity);
        // uint256 _ownershipIndex = ReturnMapping.returnOwnershipIndex(_buyer);
        // Emit an event for the purchase
        emit PreReleaseSale(msg.sender, _hashId, _numToken, _purchaseQuantity);
    }*/

    function _preReleaseValidation(bytes32 _hashId) internal {
        // Returns and decodes all values contained in releaseVal associated to hashId input
        (
            uint96 _startRelease,
            uint96 _endRelease,
            uint96 _preRelease,
            uint8 _pausedAt
        ) = ReleaseDBC.validateContentTokenReleaseData(_hashId);

        emit TestTimeValues(_startRelease, _endRelease, _preRelease, _pausedAt);

        // Returns current hourStamp
        uint96 _hourStamp = ReturnValidation._returnHourStamp();

        emit TestHourStamp(_hourStamp);

        // Ensures current hourStamp is not greater than non-zero endRelease
        if (_endRelease > 0 && _endRelease < _hourStamp) {
            revert PreReleaseSale__ExpiredSale();
        }
        // Reverts if current hourStamp is greater than or equal to startRelease (preSale ended),
        // less than preRelease (preRelease hasn't started yet), or pausedAt non-zero (active pause)
        if (
            _hourStamp >= _startRelease ||
            _hourStamp < _preRelease ||
            _pausedAt > 0
        ) {
            revert PreReleaseSale__InvalidSale();
        }
    }

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _buyer Address initiating execution.
     * @param _wavSaleToken User-defined WavSale struct.
     */
    function preReleasePurchaseSingle(
        address _buyer,
        WavSaleToken.WavSale calldata _wavSaleToken
    ) external payable {
        ReturnValidation.returnIsAuthorized();

        _preReleaseValidation(_wavSaleToken.hashId);
        // Similar to 'validateContentTokenRelease' we have to figure out if is 'sPriceUsd' or 'cPriceUsd'
        // If is 'sPriceUsd' we then have to determine price from stored numerical bitmap index
        // Determines value of Gets stored property value, decodes numToken price, returns

        /* uint256 _hashPrice = WavDBC.validateContentTokenPriceVal(_hashId, _numToken);

        _hashPrice = WavFeed.usdToWei(_hashPrice); */

        uint256 _hashPrice = ValidatePreReleaseSale._validateDebitPreRelease(
            _wavSaleToken
        );

        emit ThatFunctionWorks(true);

        if (_hashPrice > msg.value) {
            revert PreReleaseSale__InsufficientPayment();
        }

        uint256 _serviceFee = (_hashPrice * 100) / 1000;
        uint256 _creatorShare = _hashPrice - _serviceFee;

        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();

        // (original) address wavId stuff originally went after here
        address _wavId = CreatorProfitStructStorage.wavId;

        /*uint256 _netProfit = LibCollaboratorReserve
            ._allocateCollaboratorReserve(_hashId, _numToken, _creatorShare);*/
        uint256 _netProfit = LibCollaboratorReserve._collaboratorReserveRouter(
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _creatorShare
        );

        CreatorProfitStructStorage.s_ethEarnings[_wavSaleToken.creatorId][
            _wavSaleToken.hashId
        ] += _netProfit;
        CreatorProfitStructStorage.s_serviceBalance[_wavId] = _serviceFee;

        {
            LibAccess._wavAccess(_buyer, _wavSaleToken);
        }
        // uint256 _ownershipIndex = ReturnMapping.returnOwnershipIndex(_buyer);
        // Emit an event for the purchase
        emit PreReleaseSale(
            _buyer,
            _wavSaleToken.hashId,
            _wavSaleToken.numToken,
            _wavSaleToken.purchaseQuantity
        );
    }
}
