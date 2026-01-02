// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../src/../3WAVi__Helpers/ReturnValidation.sol";

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
    LibFortress
} from "../../../src/3WAVi__Helpers/FacetHelpers/LibFortress.sol";

import {
    WavResaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavResaleToken.sol";

contract WavExchangeBatch {
    event WavResaleBatchQuantity(
        address indexed _buyer,
        uint256 indexed _contentCount
    );

    error WavExchange__InsufficientPayment();
    error WavExchange__InvalidSignature();
    error WavExchange__InsufficientReserves();

    /**
     * @notice Handles core logic for purchase batch of resale content.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _buyer The address initiating purchase of a Content Token.
     * @param _wavResaleToken Batch of user-defined WavResale structs.
     * @param _nonce A unique number to prevent replay attacks.
     * @param _signature The signature to verify the transaction.
     */
    function wavResaleBatch(
        address _buyer,
        WavResaleToken.WavResale[] calldata _wavResaleToken,
        uint256 _nonce,
        bytes calldata _signature
    ) external payable {
        ReturnValidation.returnIsAuthorized();
        // total required payment (price * qty)
        uint256 _valueRequired;
        for (uint256 i = 0; i < _wavResaleToken.length; ) {
            // _purchaseQuantity might need to be typecasted
            _valueRequired +=
                _wavResaleToken[i].priceInEth *
                _wavResaleToken[i].purchaseQuantity;
            unchecked {
                ++i;
            }
        }

        if (msg.value < _valueRequired)
            revert WavExchange__InsufficientPayment();

        // verify signature (front-end data signature)
        {
            bytes32 _messageHash = keccak256(
                abi.encodePacked(_nonce, msg.sender, _valueRequired)
            );
            address _signer = LibFortress._verifySignature(
                _messageHash,
                _signature
            );

            if (_signer != msg.sender) revert WavExchange__InvalidSignature();

            // Consume nonce once for entire batch
            LibFortress._checkUseUpdateNonce(_nonce, msg.sender);
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        for (uint256 i = 0; i < _wavResaleToken.length; ) {
            uint256 _contentValue = _wavResaleToken[i].priceInEth *
                _wavResaleToken[i].purchaseQuantity;
            address _seller = _wavResaleToken[i].seller;
            address _creatorId = _wavResaleToken[i].creatorId;
            bytes32 _hashId = _wavResaleToken[i].hashId;

            uint256 _sellerShare = (_contentValue * 900) / 1000;
            uint256 _creatorShare = (_contentValue * 50) / 1000;
            uint256 _serviceFee = (_contentValue * 50) / 1000;

            CreatorProfitStructStorage.s_ethEarnings[_seller][
                _hashId
            ] += _sellerShare;
            CreatorProfitStructStorage.s_ethEarnings[_creatorId][
                _hashId
            ] += _creatorShare;
            CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;

            unchecked {
                ++i;
            }
        }

        {
            // Transfer ownership to buyer
            _wavExchangeBatch(_buyer, _wavResaleToken);
        }

        emit WavResaleBatchQuantity(_buyer, _wavResaleToken.length);
    }

    /**
     * @notice Exchanges access of a Content Token batch during user resale execution.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _wavResaleToken Batch of user-defined WavResale structs.
     */
    function _wavExchangeBatch(
        address _buyer,
        WavResaleToken.WavResale[] calldata _wavResaleToken
    ) internal {
        ReturnValidation.returnIsAuthorized();

        // Load storage pointers
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        // Iterate and assign each asset
        for (uint256 i = 0; i < _wavResaleToken.length; ) {
            // Grab user current ownershipIndex
            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
                _buyer
            ];

            // Update ownership map with _hashId and _numToken values
            CreatorTokenMapStruct.s_ownershipMap[_buyer][
                _ownershipIndex
            ] = _wavResaleToken[i].hashId;
            CreatorTokenMapStruct.s_ownershipToken[_buyer][
                _ownershipIndex
            ] = _wavResaleToken[i].numToken;

            // Increment Index for next asset
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] =
                _ownershipIndex +
                1;

            // Seller balance check and debit
            address _seller = _wavResaleToken[i].seller;
            uint256 _purchaseQuantity = uint256(
                _wavResaleToken[i].purchaseQuantity
            );
            uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[_seller][
                _wavResaleToken[i].hashId
            ][_wavResaleToken[i].numToken];

            if (_sellerBalance < _purchaseQuantity)
                revert WavExchange__InsufficientReserves();

            // Update seller balances
            TokenBalanceStruct.s_tokenBalance[_seller][
                _wavResaleToken[i].hashId
            ][_wavResaleToken[i].numToken] = _sellerBalance - _purchaseQuantity;

            // Update buyer balances
            TokenBalanceStruct.s_tokenBalance[_buyer][
                _wavResaleToken[i].hashId
            ][_wavResaleToken[i].numToken] += _purchaseQuantity;

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @notice Exchanges access of a Content Token batch during user resale executions.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _wavResaleToken Batch of user-defined WavResale structs.
     */
    function wavExchangeBatch(
        address _buyer,
        WavResaleToken.WavResale[] calldata _wavResaleToken
    ) external {
        _wavExchangeBatch(_buyer, _wavResaleToken);
    }
}
