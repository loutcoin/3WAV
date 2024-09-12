// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Operating on Polygon zkEVM for L2 reduced gas fees.
Using ETH as payment leveraging trust, & pre-existing common understanding associated with ETH.
constructor

receive function (if exists)

fallback function (if exists)

external

public

internal

private

Within grouping, view and pure functions last.
*/
// Simple Unit + Fuzz Tests + Initial Testnet deployment testing
import {WavRoot} from "../src/WavRoot.sol";
import {WavAccess} from "../src/WavAccess.sol";
import {WavFeed} from "../src/WavFeed.sol";
import {WavToken} from "../src/WavToken.sol";

contract WavStore is WavRoot {
    event MusicPurchased(
        address indexed artistId,
        uint256 indexed contentId,
        address indexed buyer
    );

    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();
    error WavStore__ArtistOrContentIdInvalid();

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
        uint256 _contentPriceInEth
    ) public payable {
        // Ensure the music exists
        if (s_musicFiles[_artistId][_contentId].artistId == address(0)) {
            revert WavStore__ArtistOrContentIdInvalid();
        }
        // Retrieve the music details from storage
        Music storage music = s_musicFiles[_artistId][_contentId];

        // Ensure the payment is sufficient
        if (msg.value < _contentPriceInEth) {
            revert WavStore__InsufficientPayment();
        }

        // Update the earnings of the artist and the service
        s_earnings[_artistId] += (msg.value * 80) / 100;
        s_earnings[address(this)] += (msg.value * 20) / 100;

        // Update the ownership of the music
        uint256 currentIndex = s_userContentIndex[msg.sender];
        s_ownershipAudio[msg.sender][currentIndex] = Music({
            artistId: _artistId,
            contentId: _contentId,
            tokenURI: music.tokenURI,
            isOwner: true
        });
        s_userContentIndex[msg.sender] += 1; // Increment the content index

        // Grant access to the purchased music
        WavAccess(s_WavAccess).wavAccess(msg.sender, _contentId, _artistId);

        // Emit an event for the purchase
        emit MusicPurchased(_artistId, _contentId, msg.sender);
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

    // Function to get music details
    function getMusicDetails(
        address _artistId, // Artist's unique ID
        uint256 _contentId // Content's unique ID
    ) internal view returns (Music storage) {
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
}
