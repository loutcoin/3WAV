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

contract WavStore is WavRoot {
    WavToken WAVT;

    event PreSalePausing(bytes32 indexed _hashId, uint256 indexed _pausedAt);

    event PreSaleResume(bytes32 indexed _hashId);

    event MusicPurchased(
        address indexed artistId,
        uint256 indexed contentId,
        address indexed buyer
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

    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();
    error WavStore__ArtistOrContentIdInvalid();
    error WavStore__IsNotCollection();
    error WavStore__PreSaleNotFound();
    error WavStore__PreSaleIsPaused();
    error WavStore__PreSaleNotPaused();

    address s_lout;
    address s_WavAccess;

    constructor(address _wavAccess) {
        s_WavAccess = _wavAccess;
        s_lout = msg.sender;
    }

    mapping(address => uint256) public s_earnings;
    mapping(bytes32 => PreRelease) public s_preSales;

    uint32 internal constant PRE_SALE_PAUSE_COUNT_DOWN = 1800; // 1800 seconds == 30 minutes

    /**
     * @notice Updates the Lout address to a new address.
     * @dev Exclusive to current address(s_lout). Updates state to reflect new official address(s_lout).
     * @param _newLoutAddr The new Lout address.
     */
    function updateLoutAddr(address _newLoutAddr) external {
        onlyLout();
        s_lout = _newLoutAddr;
    }

    /**
     * @notice Adds a new address to the list of currently authorized addresses.
     * @dev Callable exclusively by authorized addresses. Grants authorized access to specified address.
     * @param _addr The address to authorize.
     */
    function addApprovedAddr(address _addr) external {
        if (!s_authorizedAddrs[msg.sender]) {
            revert WavStore__IsNotLout();
        }
        s_authorizedAddr[_addr] = true;
    }

    /**
     * @notice Removes an address from the list of authorized addresses.
     * @dev Callable exclusively by current address(s_lout). Removes an address authorized access.
     * @param _addr The address to removed from the authorized list.
     */
    function removeApprovedAddr(address _addr) external {
        onlyLout();
        s_authorizedAddr[_addr] = false;
    }

    /**
     * @notice Initiates 'pauseAt' countdown for specific content in active pre-sale. Emits `PreReleasePausing` event when set.
     * @dev Callable exclusively by authorized addresses. When 'pauseAt' countdown is elapsed, preSale enters 'paused' state.
     * @param _hashId The unique identifier for the pre-sale.
     */
    function preSalePause(bytes32 _hashId) external {
        if (s_authorizedAddr[msg.sender] != true) {
            revert WavStore__IsNotLout();
        }
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
        if (s_authorizedAddr[msg.sender] != true) {
            revert WavStore__IsNotLout();
        }
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
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _contentPriceInEth The price of the content in ETH, calculated on the front-end.
     */
    function ethForWav(
        address _artistId,
        uint256 _contentId,
        uint256 _contentPriceInEth,
        uint16 _numCollaborators
    ) public payable {
        // Ensure the music exists
        if (s_musicFiles[_artistId][_contentId].artistId == address(0)) {
            revert WavStore__ArtistOrContentIdInvalid();
        }
        // Ensure the payment is sufficient
        if (msg.value < _contentPriceInEth) {
            revert WavStore__InsufficientPayment();
        }

        // Update the earnings of the artist and the service
        s_earnings[_artistId] += (msg.value * 80) / 100;
        s_earnings[address(this)] += (msg.value * 20) / 100; // swap for dynamic values

        // Grant access to the purchased music
        WavAccess(s_WavAccess).wavAccess(
            msg.sender,
            _artistId,
            _contentId,
            _numCollaborators
        );

        // Emit an event for the purchase
        emit MusicPurchased(_artistId, _contentId, msg.sender);
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
        if (s_authorizedAddr[msg.sender] != true) {
            revert WavStore__IsNotLout();
        }

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
        WavAccess(s_WavAccess).wavAccess(
            msg.sender,
            _artistId,
            _contentId,
            _numCollaborators
        );

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
     * @param _to The address to send the funds to.
     * @param _amount The amount to withdraw.
     */
    function withdrawEarnings(
        address _to, // Address to send the funds to
        uint256 _amount // Amount to withdraw
    ) public {
        // Ensure caller has enough balance
        if (s_earnings[msg.sender] < _amount) {
            revert WavStore__InsufficientEarnings();
        }
        // Update caller's balance
        s_earnings[msg.sender] -= _amount;
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
        address seller,
        uint256 contentId,
        uint256 priceInEth,
        uint256 ownershipIndex,
        uint256 nonce,
        bytes memory signature
    ) internal {
        if (msg.value < priceInEth) {
            revert WavStore__InsufficientPayment();
        }

        // Verify the signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(nonce, msg.sender, priceInEth)
        );
        address signer = verifySignature(messageHash, signature);
        if (signer != msg.sender) {
            revert WavFortress__InvalidSignature();
        }

        // Verify ownership using the provided ownership index
        Music storage music = s_ownershipAudio[seller][ownershipIndex];
        if (
            music.artistId == address(0) ||
            !music.isOwner ||
            music.contentId != contentId
        ) {
            revert WavStore__NotOwner();
        }

        // Check use update nonce
        checkUseUpdateNonce(nonce);

        // Calculate fees
        uint256 sellingUserShare = (msg.value * 90) / 100;
        uint256 artistShare = (msg.value * 5) / 100;
        uint256 serviceShare = (msg.value * 2.5) / 100;
        uint256 collaboratorShare = (msg.value * 2.5) / 100;

        // Revoke seller's ownership
        music.isOwner = false;

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

    function onlyLout() internal view {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
    }
}
