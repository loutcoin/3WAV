// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract WavAccess {
    error WavAccess__NameIsTaken();

    mapping(string => address) public s_artistAddr;
    // Mapping to store music owners by artistId and contentId
    mapping(address => mapping(uint256 => address[])) public s_musicOwners;

    // Function to register an artist
    function registerArtist(string memory _name, address _userAddress) public {
        checkNameTaken(_name);
        s_artistAddr[_name] = _userAddress;
    }

    function checkNameTaken(string memory _name) public view returns (bool) {
        if (s_artistAddr[_name] != address(0)) {
            revert WavAccess__NameIsTaken();
        } else return true;
    }
}
