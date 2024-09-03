// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* Operating on Polygon zkEVM for L2 reduced gas fees.
Using ETH as payment leveraging trust, & pre-existing common understanding associated with ETH.
*/
// Simple Unit + Fuzz Tests + Initial Testnet deployment testing

import {WavAccess} from "../src/WavAccess.sol";

contract WavStore {
    error WavStore__InsufficientEarnings();
    error WavStore__InsufficientPayment();
    error WavStore__IsNotLout();

    struct Music {
        address artistId;
        uint256 contentId;
        string tokenURI;
        address[] owners;
    }

    address s_lout;
    address s_WavAccess;

    constructor(address _wavAccess) {
        s_WavAccess = _wavAccess;
        s_lout = msg.sender;
    }

    // Mapping to store music files by artistId and contentId
    mapping(address artist => mapping(uint256 content => Music))
        public s_musicFiles;
    mapping(address => uint256) public s_earnings;

    function ethForWav(
        string memory _artistId,
        uint256 _contentId
    ) public payable {}

    // Function to withdraw funds
    function withdrawFunds(
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
    ) public view returns (Music memory) {
        // Return the details of the specified music file
        return s_musicFiles[_artistId][_contentId];
    }

    function updateLoutAddr(address _newLoutAddr) external {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
        s_lout = _newLoutAddr;
    }

    function onlyLout() internal view {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
    }
}
