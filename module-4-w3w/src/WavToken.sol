// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

contract WavToken is WavRoot {
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();
    error WavToken__BitmapOverflow();

    enum AudioSaleType {
        SeperateSaleAll,
        SeperateSaleSpecific
    }

    enum VariantSaleType {
        UsdSale,
        RaritySale
    }

    struct MusicToken {
        // totalSupply in context of collection == totalSupply of collection as entire entity itself, where indv songs...
        // IE: singles, for instace, could have a greater supply individually, but still be part of collection
        uint256 totalSupply; // Max Supply that can ever circulate or be owned (either fixed/limited, or nearly unlimited)
        uint256 priceInUsd; // Price in USD for simplicity (converted to ETH) (future plans to accept LOUT as well)
        uint256 releaseDate;
        uint16 numAudio;
        uint256 bitmap; // block.timestamp of when audio becomes available for purchase
        /*
        bool hasCollaborators; // Automates process of single transaction compensation upon sale of audio to featured collaborators
        bool enableVariants; // Enables variations of core audio
        bool enableDynamicSupply; // Enables initial:totalSupply and additional parameters related to varied release schedule, etc. (think limited sneaker releases/roll-out(allows for "pre-release" also, IE: pre-release purchase of video game))
        bool enableOwnerRewards; // Enables a lot of different potential functionality. (IE: You can only purchase or access this song, if you own this song, or this number of songs, fine-tuned reward control, etc.)
        bool enableBurnRewards; // Promotes the circulation of limited media. Burn your ownership to put it back in circulation for someone else and get a reward of some kind for doing so. */
    }

    struct IndividualSale {
        AudioSaleType typeSaleAudio;
        uint256 standardPriceUsd;
    }

    struct audioPriceTiers {
        uint256 accessiblePriceUsd;
        uint256 designerPriceUsd; // likely needs slight update, ONLY songs designated for specific/ALL sale to be indv sold
        mapping(uint16 => uint256) songPrices; // Mapping of numAudio index to price tier
    }

    //mapping(uint16 => uint256) songPrices;

    struct MusicTokenVariants {
        VariantSaleType typeSaleVariant;
        uint16 numVariant; // number of NFT-style 'variations' of core audio (single or collection)
        //uint16 numBonusAudio;
        //mapping(uint16 numVariant => uint16 numBonusAudio) variantBonusContent; // allow bonus audio, but also (optional) allow the modification of the core audio
    } // add enum 'release types (random chance, rarity-based, static/dynamic USD prices)

    struct Collaborator {
        address collaborator; // address of collaboratorAddress
        uint256 earningsContentSplit; // numerical split of total earnings they should recieve for each sale
    }

    struct DynamicSupply {
        uint256 initialSupply; // each song in collection starts at initialSupply
        mapping(uint16 => uint256) songSupplies; // specific song supply can be increased independently of one another
    }

    struct ArtistReserve {
        uint256 artistCopyReserve; // artists can 'mint' 20% of collection copies to self (totalSupply even if InitialSupply==true)
        uint256 fanRewardReserve; // Additional reserve for fan rewards, total reserve (artist + fan) <= 30%
    }

    // Defined bit positions for MusicToken and sub-structs
    uint8 constant MUSIC_TOKEN__IS_COLLECTION = 0;
    uint8 constant MUSIC_TOKEN__HAS_COLLABORATORS = 1;
    uint8 constant MUSIC_TOKEN__ENABLE_VARIANTS = 2;
    uint8 constant MUSIC_TOKEN__ENABLE_DYNAMIC_SUPPLY = 3;
    uint8 constant MUSIC_TOKEN__ENABLE_ARTIST_RESERVE = 4;
    uint8 constant MUSIC_TOKEN__ENABLE_REWARDS = 5;
    uint8 constant IS_COLLECTION__ENABLE_INDIVIDUAL_SALE = 6;
    uint8 constant INDIVIDUAL_SALE__ENABLE_PRICE_TIERS = 7; // Enables tiered pricing each song: Accessible, Standard, Designer
    uint8 constant VARIANTS__HAS_BONUS_CONTENT = 8; // remove songs defined in 'base audio'
    uint8 constant VARIANTS__MODIFY_CONTENT_FROM_BASE = 9;

    /**
     * @notice Stores detailed information about each music token, including supply, price, and features.
     * @dev Maps an artist's address and content ID to the MusicToken struct.
     */
    mapping(address => mapping(uint256 => MusicToken)) public s_musicTokens;

    /**
     *@notice Stores information regarding allocation of artist and fan music token reserves
     *@dev Maps an artist's address and content ID to the ArtistReserve struct
     */
    mapping(address => mapping(uint256 => ArtistReserve))
        public s_artistReserves;

    /**
     * @notice Stores information about collections of music, including the number of songs and individual sale options.
     * @dev Maps an artist's address and content ID to the MusicTokenCollection struct.
     */
    //  mapping(address => mapping(uint256 => MusicTokenCollection))
    //    public s_musicCollections;

    /**
     * @notice Stores information about collaborators for each piece of music.
     * @dev Maps an artist's address, content ID, and collaborator index to the Collaborator struct.
     */
    mapping(address => mapping(uint256 => mapping(uint16 => Collaborator)))
        public s_collaborators;

    /**
     * @notice Stores information about the supply of each song within a collection.
     * @dev Maps an artist's address and content ID to the DynamicSupply struct.
     */
    mapping(address => mapping(uint256 => DynamicSupply))
        public s_DynamicSupplies;

    /**
     * @notice Stores information about the prices of individual songs within a collection.
     * @dev Maps an artist's address and content ID to the IndividualSale struct.
     */
    mapping(address => mapping(uint256 => IndividualSale))
        public s_individualSales;

    /**
     * @notice Stores information about variants of the music tokens.
     * @dev Maps an artist's address and content ID to the MusicTokenVariants struct.
     */
    mapping(address => mapping(uint256 => MusicTokenVariants))
        public s_variants;

    mapping(uint16 => uint256) songContentIds; // Mapping of numAudio index to contentId

    /**
     * @notice Adds collaborators to a specific piece of music.
     * @dev This function is called internally to add collaborators to the s_collaborators mapping.
     *      It also updates the number of collaborators in the Music struct.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _collaborators An array of Collaborator structs containing the collaborator addresses and their earnings splits.
     */ // NEED: to set access controls and ensure after being set cannot be 'reset' without contacting LOUT
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
     * @notice Checks if the proposed reserves are within the allowed limits.
     * @param totalSupply The total supply of the music token.
     * @param artistReserve The proposed artist reserve.
     * @param fanReserve The proposed fan reward reserve.
     * @return bool indicating whether the reserves are valid.
     */
    function checkReserves(
        uint256 totalSupply,
        uint256 artistReserve,
        uint256 fanReserve
    ) public pure returns (bool) {
        if (artistReserve > (totalSupply * 20) / 100) {
            return false; // Artist reserve exceeds 20%
        }
        if (artistReserve + fanReserve > (totalSupply * 30) / 100) {
            return false; // Total reserve exceeds 30%
        }
        return true; // Reserves are valid
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
        if (!s_musicTokens[_artistId][_contentId].isCollection) {
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
        return s_musicTokens[_artistId][_contentId].priceInUsd;
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

    function setFlags(
        uint256 _bitmap,
        uint8[] memory positions
    ) internal pure returns (uint256) {
        for (uint8 i = 0; i < positions.length; i++) {
            if (positions[i] > 256) {
                revert WavToken__BitmapOverflow();
            }
            _bitmap |= (1 << positions[i]);
        }
        return _bitmap;
    }

    function clearFlags(
        uint256 _bitmap,
        uint8[] memory positions
    ) internal pure returns (uint256) {
        for (uint8 i = 0; i < positions.length; i++) {
            if (positions[i] > 256) {
                revert WavToken__BitmapOverflow();
            }
            _bitmap &= ~(1 << positions[i]);
        }
        return _bitmap;
    }

    function areFlagsSet(
        uint256 _bitmap,
        uint8[] memory positions
    ) internal pure returns (bool[] memory) {
        bool[] memory results = new bool[](positions.length);
        for (uint8 i = 0; i < positions.length; i++) {
            if (positions[i] > 256) {
                revert WavToken__BitmapOverflow();
            }
            results[i] = (_bitmap & (1 << positions[i])) != 0;
        }
        return results;
    }
}
