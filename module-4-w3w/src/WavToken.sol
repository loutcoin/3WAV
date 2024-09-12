// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

contract WavToken is WavRoot {
    struct MusicToken {
        uint256 totalSupply; // Max Supply that can ever circulate or be owned (either fixed/limited, or nearly unlimited)
        uint256 priceInUsd; // Price in USD for simplicity (converted to ETH) (future plans to accept LOUT as well)
        uint256 releaseDate; // block.timestamp of when audio becomes available for purchase
        uint16 numAudio; // number of audio being released as single body (single == 1 numAudio, 10 song album == 10 numAudio)
        bool hasCollaborators; // Automates process of single transaction compensation upon sale of audio to featured collaborators
        bool enableVariants; // Enables variations of core audio
        bool enableMultiSupply; // Enables initial:totalSupply and additional parameters related to varied release schedule, etc. (think limited sneaker releases/roll-out(allows for "pre-release" also, IE: pre-release purchase of video game))
        bool enableSupplyTracking; // Ability to easily view/"track" who owns an artists music. Enables a lot of different potential functionality. (IE: You can only purchase or access this song, if you own this song, or this number of songs, fine-tuned reward control, etc.)
        bool enableBurnRewards; // Promotes the circulation of limited media. Burn your ownership to put it back in circulation for someone else and get a reward of some kind for doing so.
    }

    struct MusicTokenVariants {
        uint16 numVariants;
        uint256[] priceVariants;
    }

    struct Collaborator {
        address collaborator;
        uint256 earningsContentSplit;
    }

    mapping(address => mapping(uint256 => MusicToken)) public s_musicTokens;
    mapping(address => mapping(uint256 => mapping(uint16 => Collaborator)))
        public s_collaborators;

    // needs to address split percentage assignment also in single efficient transaction
    function addCollaborators(
        address _artistId,
        uint256 _contentId,
        Collaborator[] memory _collaborators
    ) internal {
        for (uint16 i = 0; i < _collaborators.length; i++) {
            s_collaborators[_artistId][_contentId][i] = _collaborators[i];
        }
        // Update the number of collaborators in the Music struct
        WavRoot.s_musicFiles[_artistId][_contentId].numCollaborators = uint16(
            _collaborators.length
        );
    }

    function getMusicTokenPrice(
        address _artistId,
        uint256 _contentId
    ) public view returns (uint256) {
        return s_musicTokens[_artistId][_contentId].priceInUsd;
    }
}
