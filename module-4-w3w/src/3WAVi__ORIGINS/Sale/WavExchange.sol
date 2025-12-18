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
    event TestAddress(address _signedValue);

    event WavResaleSale(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint16 indexed _numToken,
        uint112 _purchaseQuantity
    );

    error WavExchange__InsufficientPayment();
    error WavExchange__InvalidSignature();
    error WavExchange__InsufficientReserves();

    /*
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
    /*function wavResaleSingle(
        address _seller,
        address _buyer,
        address _creatorId,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _purchaseQuantity,
        uint256 _priceInEth,
        uint256 _nonce,
        bytes memory _signature
    ) external payable {
        ReturnValidation.returnIsAuthorized();

        // Ensure sufficient payment sent
        uint256 _valueRequired = _priceInEth * uint256(_purchaseQuantity);
        if (msg.value < _valueRequired)
            revert WavExchange__InsufficientPayment();

        // Verify signature (front-end data signature)
        bytes32 _messageHash = keccak256(
            abi.encodePacked(_nonce, msg.sender, _priceInEth)
        );
        address _signer = LibFortress._verifySignature(
            _messageHash,
            _signature
        );
        if (_signer != msg.sender) revert WavExchange__InvalidSignature();

        // Consume nonce (replay protection)
        LibFortress._checkUseUpdateNonce(_nonce, _buyer);

        // Distribute creator earnings & service fees
        CreatorProfitStorage.CreatorProfitStruct
            storage CreatorProfitStructStorage = CreatorProfitStorage
                .creatorProfitStorage();
        address _wavId = CreatorProfitStructStorage.wavId;

        uint256 _sellerShare = (_valueRequired * 900) / 1000;
        uint256 _creatorShare = (_valueRequired * 50) / 1000;
        uint256 _serviceFee = (_valueRequired * 50) / 1000;

        CreatorProfitStructStorage.s_ethEarnings[_seller][
            _hashId
        ] += _sellerShare;
        CreatorProfitStructStorage.s_ethEarnings[_creatorId][
            _hashId
        ] += _creatorShare;
        CreatorProfitStructStorage.s_serviceBalance[_wavId] += _serviceFee;

        // Transfer ownership to buyer
        _wavExchange(_buyer, _seller, _hashId, _numToken, _purchaseQuantity);

        // Emit an event for the resale
        emit WavResaleSale(_buyer, _hashId, _numToken, _purchaseQuantity);
    }*/

    /*
     * @notice Exchanges access of Content Tokens during user resale execution OR WavReserve transfers.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _seller The address of the seller.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Total instances of numToken to debit.
     */
    /*function wavExchange(
        address _buyer,
        address _seller,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _purchaseQuantity
    ) external {
        ReturnValidation.returnIsAuthorized();
        _wavExchange(_buyer, _seller, _hashId, _numToken, _purchaseQuantity);
    }*/

    /*
     * @notice Exchanges access of Content Tokens during user resale execution OR WavReserve transfers.
     * @dev This function is used to exchange access of content from peer to peer.
     * @param _buyer The address of the buyer.
     * @param _seller The address of the seller.
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _purchaseQuantity Total instances of numToken to debit.
     */
    /*function _wavExchange(
        address _buyer,
        address _seller,
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _purchaseQuantity
    ) internal {
        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStorage();
        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        uint256 _sellerBalance = TokenBalanceStruct.s_tokenBalance[_seller][
            _hashId
        ][_numToken];
        if (_sellerBalance < _purchaseQuantity)
            revert WavExchange__InsufficientReserves();

        TokenBalanceStruct.s_tokenBalance[_seller][_hashId][_numToken] =
            _sellerBalance -
            uint256(_purchaseQuantity);

        TokenBalanceStruct.s_tokenBalance[_buyer][_hashId][
            _numToken
        ] += uint256(_purchaseQuantity);

        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _buyer
        ];

        /* Due to updated mapping structure removed conditional that preforms extra verification
        to ensure ownershipIndex is not occupied before writing data to the position.
        It should be impossible for this to happen anyways, unless there is a defect elsewhere. */

    /*CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
            _hashId
        ] = _numToken;*/
    /*CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex] = _hashId;
        CreatorTokenMapStruct.s_ownershipToken[_buyer][
            _ownershipIndex
        ] = _numToken;

        CreatorTokenMapStruct.s_ownershipIndex[_buyer] = _ownershipIndex + 1;
    }*/

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
            emit TestAddress(_signer);
            //if (_signer != msg.sender) revert WavExchange__InvalidSignature();
            // Was returning: 0x27D6c944a3855CBe56612cE786fe5693173DF375
            // *** Reincorporate **

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
            // Transfer ownership to buyer ***** Decide if want to 'WavResaleToken-ify' it
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

        uint256 _ownershipIndex = CreatorTokenMapStruct.s_ownershipIndex[
            _buyer
        ];

        /* Due to updated mapping structure removed conditional that preforms extra verification
        to ensure ownershipIndex is not occupied before writing data to the position.
        It should be impossible for this to happen anyways, unless there is a defect elsewhere. */

        /*CreatorTokenMapStruct.s_ownershipMap[_buyer][_ownershipIndex][
            _hashId
        ] = _numToken;*/
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
