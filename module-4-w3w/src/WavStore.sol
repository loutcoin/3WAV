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

    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();
    error WavStore__ArtistOrContentIdInvalid();
    error WavStore__IsNotCollection();

    address s_lout;
    address s_WavAccess;

    constructor(address _wavAccess) {
        s_WavAccess = _wavAccess;
        s_lout = msg.sender;
    }

    mapping(address => uint256) public s_earnings;

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
        } /*
        // Retrieve the music details from storage // implement through front-end gasless call
        Music storage music = s_musicFiles[_artistId][_contentId]; */

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

    function _purchaseResale(
        // be approvedAddr (ie: Contract, LOUT/LOUT_DEV)
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

    // Function to withdraw funds
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
     * @notice Retrieves the music details for a given artist and content ID.
     * @dev This function is called internally to fetch the details of a specific piece of music from the s_musicFiles mapping.
     *      It ensures that the music exists before returning its details.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @return Music struct details.
     * @custom:usage This function is used to retrieve music details in a gasless manner before making on-chain transactions.
     *               It should be called by the front-end to get the necessary details for further processing.
     */
    function getMusicDetails(
        address _artistId,
        uint256 _contentId
    ) internal view returns (Music storage) {
        // Ensure the music exists
        if (s_musicFiles[_artistId][_contentId].artistId == address(0)) {
            revert WavStore__ArtistOrContentIdInvalid();
        }
        // Return the details of the specified music file
        return s_musicFiles[_artistId][_contentId];
    }

    function updateLoutAddr(address _newLoutAddr) external {
        onlyLout();
        s_lout = _newLoutAddr;
    }

    function onlyLout() internal view {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
    }

    function addApprovedAddr(address _addr) external onlyOwner {
        s_authorizedAddr[_addr] = true;
    }

    function removeApprovedAddr(address _addr) external onlyOwner {
        s_authorizedAddr[_addr] = false;
    }
}
