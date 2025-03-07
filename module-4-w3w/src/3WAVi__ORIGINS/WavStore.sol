// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Operating on Polygon zkEVM for L2 reduced gas fees.
Using ETH as payment leveraging trust, & pre-existing common understanding associated with ETH.
-
~ General Timeline:
Finish back-end foundation => unit, fuzz, integration testing => Polygon zkEVM testnet deployment + front-end integration ==
Functional portfolio iteration => job camp + continue improving where possible => (once thoroughly vetted/iterated) => market release
-
[Personal Reference- Order of OP:
constructor

receive function (if exists)

fallback function (if exists)

external

public

internal

private

Within grouping, view and pure functions last.]
*/
import {WavRoot} from "../src/WavRoot.sol";
import {WavFortress} from "../src/WavFortress.sol";
import {WavAccess} from "../src/WavAccess.sol";
import {WavFeed} from "../src/WavFeed.sol";
import {WavToken} from "../src/WavToken.sol";

import {AuthorizedAddrs} from "../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrs.sol";
// CreatorToken
import {CreatorTokenStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {CreatorTokenMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
import {TokenBalanceStorage} from "../src/Diamond__Storage/CreatorToken/TokenBalanceStorage.sol";
import {CreatorProfitStorage} from "../src/Diamond__Storage/CreatorToken/CreatorProfitStorage.sol";
// ContentToken
import {SpecialLimitedSalesMap} from "../src/Diamond__Storage/ContentToken/Optionals/SpecialLimitedSalesMap.sol";
import {ContentTokenSearchStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
//Helpers
import {ReturnMapping} from "../src/3WAVi__Helpers/ReturnMapping.sol";

contract WavStore is WavRoot {
    WavToken WAVT;

    event PreSalePausing(bytes32 indexed _hashId, uint256 indexed _pausedAt);

    event PreSaleResume(bytes32 indexed _hashId);

    event MusicPurchased(
        address indexed _buyer,
        bytes32 indexed _hashId,
        uint64 indexed _purchaseQuantity
    );

    event MusicResale(
        address indexed seller,
        address indexed buyer,
        uint256 indexed contentId,
        uint256 priceInEth
    );

    event PreReleaseSale(
        address _artistId,
        uint256 _contentId,
        uint256 _priceInEth,
        uint16 _numCollaborator
    );

    error WavStore__HashResultInvalid();
    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();
    error WavStore__InsufficientTokenSupply();
    error WavStore__ArtistOrContentIdInvalid();
    error WavStore__IsNotCollection();
    error WavStore__IndexIssue();
    error WavStore__PreSaleNotFound();
    error WavStore__PreSaleIsPaused();
    error WavStore__PreSaleNotPaused();

    constructor(address _wavAccess) {
        s_WavAccess = _wavAccess;
        s_lout = msg.sender;
    }

    uint32 internal constant PRE_SALE_PAUSE_COUNT_DOWN = 1800; // 1800 seconds == 30 minutes

    /**
     * @notice Initiates 'pauseAt' countdown for specific content in active pre-sale. Emits `PreReleasePausing` event when set.
     * @dev Callable exclusively by authorized addresses. When 'pauseAt' countdown is elapsed, preSale enters 'paused' state.
     * @param _hashId The unique identifier for the pre-sale.
     */
    function preSalePause(bytes32 _hashId) external {
        returnIsAuthorizedAddr(msg.sender);

        if (s_preSales[_hashId].preReleaseStart == 0) {
            revert WavStore__PreSaleNotFound();
        }
        uint256 _pausedAt = block.timestamp +
            uint256(PRE_SALE_PAUSE_COUNT_DOWN);
        s_preSales[_hashId].pausedAt = _pausedAt;

        emit PreSalePausing(_hashId, _pausedAt);
    }
    /**
     * @notice Resumes pre-sale of content currently in paused state. Emits `PreSaleResume` upon doing so.
     * @dev Callable exclusively by authorized addresses. Resets 'pauseAt' to '0', reinstating pre-sale.
     * @param _hashId The unique identifier for the pre-sale.
     */
    function preSaleResume(bytes32 _hashId) external {
        returnIsAuthorizedAddr(msg.sender);
        if (s_preSales[_hashId].preReleaseStart == 0) {
            revert WavStore__PreSaleNotFound();
        }
        if (s_preSales[_hashId].pausedAt < 0) {
            revert revertWavStore__PreSaleNotPaused();
        }
        s_preSales[_hashId].pausedAt = 0;
        emit PreSaleResume(_hashId);
    }

    /**
     * @notice Allows a user to purchase music using ETH.
     * @param _creatorId The address of the artist.
     * @param _ownershipIndex The historical ownership index of the user.
     * @param _hashId The unique hashId of the content token.
     * @param _contentPriceInEth The price of the content in ETH, calculated on the front-end.
     */
    function ethForWav(
        address _beneficiaryId,
        address _creatorId,
        bytes32 _hashId,
        uint256 _purchaseQuantity,
        uint64 _priceInEth // really should be like a uint64
    ) external payable {
        returnIsAuthorizedAddr(msg.sender);

        address _publisherId = returnTokenPublisher(_hashId);
        // Ensure Content Token is valid
        if (_publisherId != _creatorId && _creatorId == address(0)) {
            revert WavStore__ArtistOrContentIdInvalid();
        }

        uint256 _ownershipIndex = returnOwnershipIndex(_buyer);

        if (msg.value < _contentPriceInEth) {
            revert WavStore__InsufficientPayment();
        }

        uint256 _remainder = validatePurchaseQuantity(
            _hashId,
            _purchaseQuantity
        );

        TokenBalanceStorage.TokenBalance
            storage tokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        tokenBalanceStruct.s_remainingSupply[_hashId] = _remainder;

        CreatorProfitStorage.CreatorProfitMap
            storage creatorProfitMapStruct = CreatorProfitStorage
                .creatorProfitMapStructStorage();

        // Update the earnings of the artist and the service
        creatorProfitMapStruct.s_ethEarnings[_creatorId] +=
            (msg.value * 80) /
            100;
        creatorProfitMapStruct.s_ethEarnings[address(this)] +=
            (msg.value * 20) /
            100; // swap for dynamic values

        // Grant access to the purchased music *update; already updates balance += purchaseQuantity
        WavAccess(s_WavAccess).wavAccess(
            _beneficiaryId,
            _ownershipIndex,
            _purchaseQuantity,
            _hashId
        );

        // Emit an event for the purchase
        emit MusicPurchased(_beneficiaryId, _hashId, _purchaseQuantity);
    }

    /**
     * @notice Facilitates purchase, in ETH, of content in active pre-sale. Emits `PreReleaseSale` upon successful execution.
     * @dev Exclusive to authorized addresses. Verifies pre-sale state, and transfers ownership and payment sufficiency.
     * @param _artistId The address of the artist.
     * @param _contentId The unique identifier of the content.
     * @param _contentPriceInEth The price of the content in ETH.
     * @param _numCollaborators The number of collaborators involved.
     */
    function preReleaseEthSale(
        address _artistId,
        uint256 _contentId,
        uint256 _contentPriceInEth,
        uint16 _numCollaborators
    ) public payable {
        // Ensure caller is authorized
        /*  if (s_authorizedAddr[msg.sender] != true) {
            revert WavStore__IsNotLout();
        } */
        returnIsAuthorizedAddr(msg.sender);

        // Check if pre-release is paused
        if (s_preSales[_contentId].pausedAt > block.timestamp) {
            revert WavStore__PreSalePaused();
        }

        // Ensure the payment is sufficient
        if (msg.value < _contentPriceInEth) {
            revert WavStore__InsufficientPayment();
        }

        // Update the earnings
        s_earnings[_artistId] += (msg.value * 80) / 100;
        s_earnings[address(this)] += (msg.value * 20) / 100;

        // Grant access to the purchased music
        WavAccess(s_WavAccess).wavAccess(msg.sender, _ownershipIndex, _hashId);

        // Emit an event for the purchase
        emit PreReleaseSale(_artistId, _contentId, msg.sender);
    }

    /**
     * @notice Authorized addresses only! Facilitates the purchase of resale content.
     * @dev Performs access control and delegates core logic to the internal function.
     * @param seller The address of the seller.
     * @param contentId The unique identifier of the content.
     * @param priceInEth The price of the content in ETH.
     * @param ownershipIndex The index representing the ownership of the content.
     * @param nonce A unique number to prevent replay attacks.
     * @param signature The signature to verify the transaction.
     */
    function purchaseResale(
        address seller,
        uint256 contentId,
        uint256 priceInEth,
        uint256 ownershipIndex,
        uint256 nonce,
        bytes memory signature
    ) public payable {
        if (!s_authorizeddAddrs[msg.sender]) {
            revert WavStore__IsNotLout();
        }

        _purchaseResale(
            seller,
            contentId,
            priceInEth,
            ownershipIndex,
            nonce,
            signature
        );
    }

    /**
     * @notice Withdraws earnings from the caller's balance.
     * @dev Ensures sufficient balance, updates and transfers value. Gasless checks and automated inputs preformed by front-end.
     * @param _creatorId The address of the creator.
     * @param _to The address to send the funds to.
     * @param _amount The amount to withdraw.
     */
    function withdrawEthEarnings(
        address _creatorId,
        address _to, // Address to send the funds to
        uint256 _amount // Amount to withdraw
    ) public {
        uint256 _earnings = returnEthEarnings(_creatorId, _hashId);
        // Ensure caller has enough balance
        if (_earnings < _amount) {
            revert WavStore__InsufficientEarnings();
        }
        CreatorProfitStorage.CreatorProfitMap
            storage creatorProfitMapStruct = CreatorProfitStorage
                .creatorProfitMapStructStorage();
        // Update caller's balance
        creatorProfitMapStruct.s_ethEarnings[msg.sender] -= _amount;
        // Transfer specified amount to _to
        payable(_to).transfer(_amount);
    }

    /**
     * @notice Handles core logic for purchase of resale content.
     * @dev Verifies payment, signature, ownership, and updates the state. Distributes fees and transfers ownership.
     * @param seller The address of the seller.
     * @param contentId The unique identifier of the content.
     * @param priceInEth The price of the content in ETH.
     * @param ownershipIndex The index representing the ownership of the content.
     * @param nonce A unique number to prevent replay attacks.
     * @param signature The signature to verify the transaction.
     */
    function _purchaseResale(
        address _seller,
        uint256 _contentId,
        bytes32 _hashId,
        uint256 _priceInEth,
        uint256 _PurchaseQuantity,
        uint256 _ownershipIndex,
        uint256 _nonce,
        bytes memory _signature
    ) internal {
        returnIsAuthorizedAddr(msg.sender);

        if (msg.value < (priceInEth * _purchaseQuantity)) {
            revert WavStore__InsufficientPayment();
        }

        // Verify the signature
        bytes32 _messageHash = keccak256(
            abi.encodePacked(_nonce, msg.sender, _priceInEth)
        );
        address _signer = verifySignature(_messageHash, _signature);
        if (_signer != msg.sender) {
            revert WavFortress__InvalidSignature();
        }

        CreatorTokenMapStorage.CreatorTokenMap
            storage CreatorTokenMapStruct = CreatorTokenMapStorage
                .creatorTokenMapStructStorage();

        TokenBalanceStorage.TokenBalance
            storage TokenBalanceStruct = TokenBalanceStorage
                .tokenBalanceStorage();

        // Verify ownership using the provided ownership index
        bytes32 _hashResult = CreatorTokenMapStruct.s_ownershipMap[_seller][
            _ownershipIndex
        ];
        if (_hashResult != _hashId && _hashResult == bytes32(0)) {
            revert WavStore__HashResultInvalid();
        }

        uint256 _balanceResult = TokenBalanceStruct.s_tokenBalance[_seller][
            _hashId
        ];
        uint256 _updatedBalance = _balanceResult - _purchaseQuantity;
        TokenBalanceStruct.s_tokenBalance[_seller][_hashId] = _updatedBalance;

        // Check use update nonce
        checkUseUpdateNonce(nonce);

        /* Calculate fees
        uint256 sellingUserShare = (msg.value * 90) / 100;
        uint256 artistShare = (msg.value * 5) / 100;
        uint256 serviceShare = (msg.value * 2.5) / 100;
        uint256 collaboratorShare = (msg.value * 2.5) / 100;
        */

        // Revoke seller's ownership
        // music.isOwner = false;

        // Transfer ownership to buyer
        WavAccess(s_WavAccess).wavAccess(
            msg.sender,
            music.artistId,
            contentId,
            music.numCollaborators
        );

        // Distribute fees
        // payable(seller).transfer(sellingUserShare);
        // Logic to transfer artistShare to the artist
        //  payable(address(this)).transfer(serviceShare);
        // Logic to transfer collaboratorShare to collaborators (if any)

        // Emit an event for the resale
        emit MusicResale(seller, msg.sender, contentId, priceInEth);
    }

    /**
     * @notice Retrieves music details from provided artist's contentID.
     * @dev Used largely by front-end, in gasless-manner, fetching content details before making an on-chain function call.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @return Music struct details.
     */
    function getMusicDetails(
        address _artistId,
        uint256 _contentId
    ) public view returns (Music storage) {
        // Ensure the music exists
        if (s_musicFiles[_artistId][_contentId].artistId == address(0)) {
            revert WavStore__ArtistOrContentIdInvalid();
        }
        // Return the details of the specified music file
        return s_musicFiles[_artistId][_contentId];
    }

    function generateResaleSplitBatch(
        bytes32 _hashId,
        uint256 _purchaseQuantity,
        uint256 _ethPrice
    )
        public
        pure
        returns (
            uint256 _sellerSplit,
            uint256 _creatorSplit,
            uint256 _collaboratorSplit,
            uint256 _serviceSplit
        )
    {
        CollaboratorMapStorage.CollaboratorMap
            storage CollaboratorMapStruct = CollaboratorMapStorage
                .collaboratorMapStorage();

        uint256 collaboratorTotal = CollaboratorMapStruct
            .s_collaborators[_hashId]
            .collaboratorVal
            .length;

        uint256 _total = _purchaseQuantity * _ethPrice;

        _sellerSplit = (_total * 900) / 1000;
        _creatorSplit = (_total * 50) / 1000;
        _collaboratorSplit = (_total * 25) / 1000;
        _serviceShare = (_total * 25) / 1000;
    }

    function generateResaleSplitSingle(
        uint256 _purchaseQuantity,
        uint256 _ethPrice
    )
        public
        pure
        returns (
            uint256 _sellerSplit,
            uint256 _creatorSplit,
            uint256 _collaboratorSplit,
            uint256 _serviceSplit
        )
    {
        uint256 _total = _purchaseQuantity * _ethPrice;

        _sellerSplit = (_total * 900) / 1000;
        _creatorSplit = (_total * 75) / 1000;
        _serviceShare = (_total * 25) / 1000;
    }

    /**
     * @notice Validates sufficient remaining supply relative to a purchase quantity.
     * @dev Should always be called before final execution of an asset purchase.
     * @param _hashId of the asset being validated.
     * @param _purchaseQuantity of instances to be purchased.
     * @return _tokenSupplyRemainder
     */
    function validatePurchaseQuantity(
        bytes32 _hashId,
        uint256 _purchaseQuantity
    ) external view returns (uint256 _tokenSupplyRemainder) {
        uint256 _remainder = returnRemainingSupply(_hashId);
        if (_remainder < _purchaseQuantity) {
            revert WavStore__InsufficientTokenSupply();
        }
        _tokenSupplyRemainder = (_remainder - _purchaseQuantity);
        return _tokenSupplyRemainder;
    }
}
