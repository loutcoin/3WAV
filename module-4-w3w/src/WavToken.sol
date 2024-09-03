// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/* struct MusicToken {
uint256 InitialSupply
uint256 MaxSupply
uint256 price....
(the struct inspiration you created got deleted in the chat before I could add it :/)

}

*/

contract WavToken {
    struct MusicToken {
        string name;
        uint256 initialSupply;
        uint256 totalSupply;
        uint256 price;
        uint256 releaseDate;
        bool enableVariants;
    }

    struct MusicTokenVariants {
        uint16 numVariants;
        string[] variantNames;
    }
}
