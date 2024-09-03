// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WavAccess {
    error WavAccess__NameIsTaken();
    error WavAccess__IsNotApprovedArtist();
    error WavStore__IsNotLout();

    address s_lout;

    mapping(string => address) public s_artistAddr;
    mapping(address => bool) internal s_approvedArtist;
    // Mapping to store music owners by artistId and contentId
    mapping(address => mapping(uint256 => address[])) public s_musicOwners;

    // called externally outside of DApp, allowing user to register artist account with 'registerArtist'
    function approveArtist(address _userAddress) external {
        onlyLout();
        s_approvedArtist[_userAddress] = true;
    }

    // Function called by approvedArtist to register from user => artist
    function registerArtist(string memory _name, address _userAddress) public {
        if (s_approvedArtist[msg.sender] != true) {
            revert WavAccess__IsNotApprovedArtist();
        }
        checkNameTaken(_name);
        s_artistAddr[_name] = _userAddress;
    }

    function onlyLout() internal view {
        if (msg.sender != s_lout) {
            revert WavStore__IsNotLout();
        }
    }

    function checkNameTaken(string memory _name) public view {
        if (s_artistAddr[_name] != address(0)) {
            revert WavAccess__NameIsTaken();
        }
    }
}
