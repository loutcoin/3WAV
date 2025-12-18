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
    event WavResaleBatch(
        address indexed _buyer,
        bytes32[] _hashIdBatch,
        uint16[] _numToken,
        uint112[] _purchaseQuantity
    );
    error WavExchange__InsufficientPayment();
    error WavExchange__InvalidSignature();
    error WavExchange__InsufficientReserves();
    error WavExchange__LengthMismatch();

    /*
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
    /*function wavResaleBatch(
        address[] calldata _sellerBatch,
        address _buyer,
        address[] calldata _creatorIdBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _purchaseQuantityBatch,
        uint256[] calldata _priceInEthBatch,
        uint256 _nonce,
        bytes calldata _signature
    ) external payable {
        ReturnValidation.returnIsAuthorized();

        uint256 _hashLength = _hashIdBatch.length;

        // basic length checks
        if (
            _sellerBatch.length != _hashLength ||
            _creatorIdBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _priceInEthBatch.length != _hashLength
        ) revert WavExchange__LengthMismatch();

        // total required payment (price * qty)
        uint256 _valueRequired;
        for (uint256 i = 0; i < _hashLength; ) {
            _valueRequired += _priceInEthBatch[i] * _purchaseQuantityBatch[i];
            unchecked {
                ++i;
            }
        }

        if (msg.value < _valueRequired)
            revert WavExchange__InsufficientPayment();
        // verify signature (front-end data signature)
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

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        for (uint256 i = 0; i < _hashLength; ) {
            uint256 _contentValue = _priceInEthBatch[i] *
                _purchaseQuantityBatch[i];
            address _seller = _sellerBatch[i];
            address _creatorId = _creatorIdBatch[i];
            bytes32 _hashId = _hashIdBatch[i];

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
            //CreatorProfitStructStorage.serviceProfit += _serviceFee;

            unchecked {
                ++i;
            }
        }

        // Transfer ownership to buyer
        _wavExchangeBatch(
            _buyer,
            _sellerBatch,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );

        emit WavResaleBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );
    }*/

    /*
     * @notice Exchanges access of a Content Token batch during user resale executions.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _sellerBatch Batch of seller addresses.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Total instances of each numToken being debited.
     */
    /*function wavExchangeBatch(
        address _buyer,
        address[] calldata _sellerBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _purchaseQuantityBatch
    ) external {
        _wavExchangeBatch(
            _buyer,
            _sellerBatch,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );
    }*/

    /*
     * @notice Exchanges access of a Content Token batch during user resale execution.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _sellerBatch Batch of seller addresses.
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _purchaseQuantityBatch Total instances of each numToken being debited.
     */
    /*function _wavExchangeBatch(
        address _buyer,
        address[] calldata _sellerBatch,
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _purchaseQuantityBatch
    ) internal {
        ReturnValidation.returnIsAuthorized();
        uint256 _hashLength = _hashIdBatch.length;
        // Length property of all arrays should match
        if (
            _sellerBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength
        ) {
            revert WavExchange__LengthMismatch();
        }
        // Load storage pointers
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        // Iterate and assign each asset
        for (uint256 i = 0; i < _hashLength; ) {
            // Grab user current ownershipIndex
            uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
                _buyer
            ];

            // Update ownership map with _hashId and _numToken values
            /*CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
                _hashIdBatch[i]
            ] = _numTokenBatch[i];*/
    /*CreatorTokenMapStruct.s_ownershipMap[_buyer][
                _ownershipIndex
            ] = _hashIdBatch[i];
            CreatorTokenMapStruct.s_ownershipToken[_buyer][
                _ownershipIndex
            ] = _numTokenBatch[i];

            // Increment Index for next asset
            CreatorTokenMapStruct.s_ownershipIndex[_buyer] =
                _ownershipIndex +
                1;

            // Seller balance check and debit
            address _seller = _sellerBatch[i];
            uint256 _purchaseQuantity = uint256(_purchaseQuantityBatch[i]);
            uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[_seller][
                _hashIdBatch[i]
            ][_numTokenBatch[i]];
            if (_sellerBalance < _purchaseQuantity)
                revert WavExchange__InsufficientReserves();
            TokenBalanceStruct.s_tokenBalance[_seller][_hashIdBatch[i]][
                _numTokenBatch[i]
            ] = _sellerBalance - _purchaseQuantity;

            // Update buyer balances
            TokenBalanceStruct.s_tokenBalance[_buyer][_hashIdBatch[i]][
                _numTokenBatch[i]
            ] += _purchaseQuantity;

            unchecked {
                ++i;
            }
        }
    }*/

    function wavResaleBatch(
        address _buyer,
        WavResaleToken.WavResale[] calldata _wavResaleToken,
        uint256 _nonce,
        bytes calldata _signature
    ) external payable {
        ReturnValidation.returnIsAuthorized();
        // Reincorporate ****

        // basic length checks
        /*if (
            _sellerBatch.length != _hashLength ||
            _creatorIdBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _priceInEthBatch.length != _hashLength
        ) revert WavExchange__LengthMismatch();*/

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
            //if (_signer != msg.sender) revert WavExchange__InvalidSignature();

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
            //CreatorProfitStructStorage.serviceProfit += _serviceFee;

            unchecked {
                ++i;
            }
        }

        {
            // Transfer ownership to buyer
            _wavExchangeBatch(_buyer, _wavResaleToken);
        }

        /*emit WavResaleBatch(
            _buyer,
            _hashIdBatch,
            _numTokenBatch,
            _purchaseQuantityBatch
        );*/
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

        // Length property of all arrays should match
        /*if (
            _sellerBatch.length != _hashLength ||
            _purchaseQuantityBatch.length != _hashLength ||
            _numTokenBatch.length != _hashLength
        ) {
            revert WavExchange__LengthMismatch();
        }*/
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
            /*CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
                _hashIdBatch[i]
            ] = _numTokenBatch[i];*/
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
