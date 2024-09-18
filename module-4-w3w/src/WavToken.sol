// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

contract WavToken is WavRoot {
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();

    struct MusicToken {
        // totalSupply in context of collection == totalSupply of collection as entire entity itself, where indv songs...
        // could have a greater supply individually
        uint256 totalSupply; // Max Supply that can ever circulate or be owned (either fixed/limited, or nearly unlimited)
        uint256 priceInUsd; // Price in USD for simplicity (converted to ETH) (future plans to accept LOUT as well)
        uint256 releaseDate; // block.timestamp of when audio becomes available for purchase
        bool isCollection; // enable if releasing more than 'single' song / audio file as collection
        bool hasCollaborators; // Automates process of single transaction compensation upon sale of audio to featured collaborators
        bool enableVariants; // Enables variations of core audio
        bool enableMultiSupply; // Enables initial:totalSupply and additional parameters related to varied release schedule, etc. (think limited sneaker releases/roll-out(allows for "pre-release" also, IE: pre-release purchase of video game))
        bool enableSupplyTracking; // Ability to easily view/"track" who owns an artists music. Enables a lot of different potential functionality. (IE: You can only purchase or access this song, if you own this song, or this number of songs, fine-tuned reward control, etc.)
        bool enableBurnRewards; // Promotes the circulation of limited media. Burn your ownership to put it back in circulation for someone else and get a reward of some kind for doing so.
    }

    struct MusicTokenCollection {
        uint16 numAudio; // number of audio being released as single body (10 song album == 10 numAudio)
        bool enableIndividualSale; // allows for individual sale of ALL or SPECIFIC songs independent of collective experience
        mapping(uint16 => uint256) songContentIds; // Mapping of song index to contentId
    }

    struct IndividualSale {
        bool enableSeperateSaleAll;
        mapping(uint16 => uint256) songPrices;
    }

    struct MusicTokenVariants {
        uint16 numVariants; // number of NFT-style 'variations' of core audio (single or collection)
        uint256[] priceVariants;
    } // add enum 'release types (random chance, rarity-based, static/dynamic USD prices)

    struct Collaborator {
        address collaborator;
        uint256 earningsContentSplit;
    }

    struct MultiSupply {
        uint256 initialSupply;
        mapping(uint16 => uint256) songSupplies;
    }

    mapping(address => mapping(uint256 => MusicToken)) public s_musicToken;
    mapping(address => mapping(uint256 => MusicTokenCollection))
        public s_musicCollections;
    mapping(address => mapping(uint256 => mapping(uint16 => Collaborator)))
        public s_collaborators;
    mapping(address => mapping(uint256 => MultiSupply)) public s_multiSupplies;
    mapping(address => mapping(uint256 => IndividualSale))
        public s_individualSales;
    mapping(address => mapping(uint256 => MusicTokenVariants))
        public s_variants;

    /**
     * @notice Adds collaborators to a specific piece of music.
     * @dev This function is called internally to add collaborators to the s_collaborators mapping.
     *      It also updates the number of collaborators in the Music struct.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _collaborators An array of Collaborator structs containing the collaborator addresses and their earnings splits.
     */
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

    /**
     * @notice Calculates the earnings split for collaborators.
     * @dev This function is a pure function that calculates the earnings split for each collaborator.
     *      It uses the addresses and their respective splits passed as input parameters.
     * @param _collaboratorAddresses The array of collaborator addresses.
     * @param _earningsSplits The array of earnings splits for each collaborator.
     * @param totalAmount The total amount to be split among collaborators.
     * @return array of addresses and numerical array associated with corresponding amounts of each collaborator's earnings.
     */
    function calculateCollaboratorEarnings(
        address[] memory _collaboratorAddresses,
        uint256[] memory _earningsSplits,
        uint256 totalAmount
    ) public pure returns (address[] memory, uint256[] memory) {
        // Ensure the lengths of the addresses and splits arrays match
        if (_collaboratorAddresses.length != _earningsSplits.length) {
            revert WavToken__CollaboratorSplitLengthMismatch();
        }

        // Calculate the total amount available for collaborators after the service fee
        uint256 availableAmount = (totalAmount * 80) / 100;

        // Initialize arrays to store the addresses and earnings for each collaborator
        address[] memory addresses = new address[](
            _collaboratorAddresses.length
        );
        uint256[] memory earnings = new uint256[](
            _collaboratorAddresses.length
        );

        // Loop through each collaborator and calculate their earnings
        for (uint16 i = 0; i < _collaboratorAddresses.length; i++) {
            // Calculate the earnings for the collaborator
            // The earnings split is in basis points (e.g., 1000 = 10%)
            earnings[i] = (availableAmount * _earningsSplits[i]) / 10000; // replace floating nums
            addresses[i] = _collaboratorAddresses[i];
        }

        return (addresses, earnings); // _earningsSplits(1000) = 10% base point system
    }

    /**
     * @notice Retrieves the details of a music collection.
     * @dev This function is a view function that returns the details of a music collection.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the collection.
     */
    function getCollectionDetails(
        address _artistId,
        uint256 _contentId
    )
        public
        view
        returns (
            uint16 numAudio,
            bool enableIndividualSale,
            uint256[] memory songContentIds,
            bool enableSeperateSaleAll,
            uint256[] memory songPrices
        )
    {
        // Ensure the collection exists
        if (!s_musicToken[_artistId][_contentId].isCollection) {
            revert WavToken__IsNotCollection();
        }

        // Retrieve the collection details
        MusicTokenCollection storage collectionDetails = s_musicCollections[
            _artistId
        ][_contentId];
        IndividualSale storage individualSaleDetails = s_individualSales[
            _artistId
        ][_contentId];

        // Prepare arrays for songContentIds and song prices
        songContentIds = new uint256[](collectionDetails.numAudio);
        songPrices = new uint256[](collectionDetails.numAudio);

        // Populate the arrays
        for (uint16 i = 0; i < collectionDetails.numAudio; i++) {
            songContentIds[i] = collectionDetails.songContentIds[i];
            songPrices[i] = individualSaleDetails.songPrices[i];
        }

        // Return the details of the specified music collection and individual sale details
        return (
            collectionDetails.numAudio,
            collectionDetails.enableIndividualSale,
            songContentIds,
            individualSaleDetails.enableSeperateSaleAll,
            songPrices
        );
    }

    /**
     * @notice Retrieves the price of a music token in USD.
     * @dev This function is a view function that returns the price of a specific music token.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @return The price of the music token in USD.
     */
    function getMusicTokenPrice(
        address _artistId,
        uint256 _contentId
    ) public view returns (uint256) {
        return s_musicToken[_artistId][_contentId].priceInUsd;
    }

    /**
     * @notice Retrieves information about all collaborators for a piece of music.
     * @dev This function is a view function that returns the details of all collaborators.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @return array of Collaborator structs containing the collaborators' addresses and their earnings splits.
     */
    function getCollaborators(
        address _artistId,
        uint256 _contentId
    ) public view returns (Collaborator[] memory) {
        // Retrieve the number of collaborators from the Music struct
        uint16 numCollaborators = WavRoot
        .s_musicFiles[_artistId][_contentId].numCollaborators;

        // Initialize an array to store the collaborators
        Collaborator[] memory collaborators = new Collaborator[](
            numCollaborators
        );

        // Loop through each collaborator and add them to the array
        for (uint16 i = 0; i < numCollaborators; i++) {
            collaborators[i] = s_collaborators[_artistId][_contentId][i];
        }

        return collaborators;
    }
}
