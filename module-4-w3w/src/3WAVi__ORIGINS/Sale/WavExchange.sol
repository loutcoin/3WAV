// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

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

contract WavExchange {
    event WavResaleSale(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _purchaseQuantity
    );

    error WavExchange__InsufficientPayment();
    error WavExchange__InvalidSignature();
    error WavExchange__InsufficientReserves();

    /**
     * @notice Handles core logic for purchase of resale content.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param _buyer The address initiating purchase of a Content Token.
     * @param _wavResaleToken User-defined WavResale struct.
     * @param _nonce A unique number to prevent replay attacks.
     * @param _signature The signature to verify the transaction.
     */
    function wavResaleSingle(
        address _buyer,
        WavResaleToken.WavResale calldata _wavResaleToken,
        uint256 _nonce,
        bytes memory _signature
    ) external payable {
        ReturnValidation.returnIsAuthorized();

        // Ensure sufficient payment sent
        uint256 _valueRequired = _wavResaleToken.priceInEth *
            uint256(_wavResaleToken.purchaseQuantity);
        if (msg.value < _valueRequired)
            revert WavExchange__InsufficientPayment();

        {
            // Verify signature (front-end data signature)
            bytes32 _messageHash = keccak256(
                abi.encodePacked(_nonce, msg.sender, _wavResaleToken.priceInEth)
            );
            address _signer = LibFortress._verifySignature(
                _messageHash,
                _signature
            );

            if (_signer != msg.sender) revert WavExchange__InvalidSignature();

            // Consume nonce (replay protection)
            LibFortress._checkUseUpdateNonce(_nonce, _buyer);
        }

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        uint256 _sellerShare = (_valueRequired * 900) / 1000;
        uint256 _creatorShare = (_valueRequired * 50) / 1000;
        uint256 _serviceFee = (_valueRequired * 50) / 1000;

        CreatorProfitStructStorage.s_ethEarnings[_wavResaleToken.seller][
            _wavResaleToken.hashId
        ] += _sellerShare;
        CreatorProfitStructStorage.s_ethEarnings[_wavResaleToken.creatorId][
            _wavResaleToken.hashId
        ] += _creatorShare;
        CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;

        {
            // Transfer ownership to buyer
            _wavExchange(_buyer, _wavResaleToken);
        }

        // Emit an event for the resale
        emit WavResaleSale(
            _buyer,
            _wavResaleToken.hashId,
            _wavResaleToken.numToken,
            _wavResaleToken.purchaseQuantity
        );
    }

    /**
     * @notice Exchanges access of Content Tokens during user resale execution OR WavReserve transfers.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _wavResaleToken User defined WavResale struct
     */
    function _wavExchange(
        address _buyer,
        WavResaleToken.WavResale calldata _wavResaleToken
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        //WavResaleToken.WavResale calldata _wavResaleToken
        uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[
            _wavResaleToken.seller
        ][_wavResaleToken.hashId][_wavResaleToken.numToken];
        if (_sellerBalance < _wavResaleToken.purchaseQuantity)
            revert WavExchange__InsufficientReserves();

        TokenBalanceStruct.s_tokenBalance[_wavResaleToken.seller][
            _wavResaleToken.hashId
        ][_wavResaleToken.numToken] =
            _sellerBalance -
            uint256(_wavResaleToken.purchaseQuantity);

        TokenBalanceStruct.s_tokenBalance[_buyer][_wavResaleToken.hashId][
            _wavResaleToken.numToken
        ] += uint256(_wavResaleToken.purchaseQuantity);

        // After ownership index is occupied it should always be incremented
        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _buyer
        ];
        CreatorTokenMapStruct.s_ownershipMap[_buyer][
            _ownershipIndex
        ] = _wavResaleToken.hashId;
        CreatorTokenMapStruct.s_ownershipToken[_buyer][
            _ownershipIndex
        ] = _wavResaleToken.numToken;

        CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;
    }

    /**
     * @notice Exchanges access of Content Tokens during user resale execution OR WavReserve transfers.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _wavResaleToken User-defined WavResale struct.
     */
    function wavExchange(
        address _buyer,
        WavResaleToken.WavResale calldata _wavResaleToken
    ) external {
        ReturnValidation.returnIsAuthorized();
        _wavExchange(_buyer, _wavResaleToken);
    }
}
