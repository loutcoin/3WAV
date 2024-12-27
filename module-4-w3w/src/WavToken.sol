// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";

/*
WIP: OBVIOUSLY WIP! WORKING DAILY, BUT CONTRACT HAS OBVIOUS ISSUES IN CURRENT STATE AND IS INCOMPELTE.
WORKING TO CREATE CREATIVE INNOVATIVE, *useful* ZERO-CODE CUSTOM TEMPLATE SOLUTION FEATURES
ONCE COMPLETE WILL CREATE ACCESS CONTROLLED 'publishWav' FUNCTION.
WILL INTERPRET INTEGRATED FRONT-END USER INTERACTIONS, AND WITH FRONT-END SCRIPT,
GASLESS HELPER FUNCTIONS, ETC. WILL AUTONOMOUSLY PASS IN THE APPROPRIATE VALUES ON THE ARTIST'S BEHALF
AND PUBLISH THEIR AUDIO-BASED CONTENT TO THEIR PERSONALIZED NEEDS. -LOUT
*/

//Struct, Event and Error Definitions
//If struct or error is used across many files, define in own file. Multiple structs and errors defined together single file.

contract WavToken is WavRoot {
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();
    error WavToken__BitmapOverflow();
    error WavToken__RSaleMismatch();
    error WavToken__RSaleOverflow();

    struct MusicToken {
        uint256 totalSupply;
        uint256 priceInUsd;
        uint256 releaseDate;
        uint16 numAudio;
        uint256 bitmap;
        /*
        bool enableOwnerRewards; // Enables a lot of different potential functionality. (IE: You can only purchase or access this song, if you own this song, or this number of songs, fine-tuned reward control, etc.)
         */
    }

    struct IndividualSale {
        uint256 standardPriceUsd;
        uint256 seperateSaleSupplySurplus;
    } // if allow indv sale of specific tracks, should nvr exceed supply of collection itself, so indv tracks nvr sale out...
    // in collective-context

    struct AudioPriceTiers {
        IndividualSale individualSale;
        uint256 accessiblePriceUsd;
        uint256 designerPriceUsd; // likely needs slight update, ONLY songs designated for specific/ALL sale to be indv sold
    }

    /**
     * @title Variants
     * @notice Stores information about different variants of a music token.
     * @dev Defines numerical index, total audio content, and variant-specific supply.
     */
    struct Variants {
        /// @notice Numerical index of particular variant from core audio in specific published context (single or collection).
        uint16 numVariant;
        /// @notice Number of variant-specific audio tracks. If token is not collection, numVariantAudio always == 1.
        uint16 numVariantAudio;
        /// @notice Total supply of specific variant derivative.
        uint256 variantSupply;
    }

    struct IndividualSaleVariant {
        Variants variant;
        IndividualSale individualSale;
    }

    /**
     * @title UsdSaleVariant
     * @notice Stores information about USD sale variants of a music token.
     * @dev Defines variant details and price in USD.
     */
    struct UsdSaleVariant {
        /// @notice Details of the variant.
        Variants variant;
        /// @notice Price of the variant in USD.
        uint256 priceUsdVariant;
    }

    /**
     * @title RSaleVariant
     * @notice Stores information about rarity sale variants of a music token.
     * @dev Defines variant details for singular RSale-type.
     */
    struct RSaleVariant {
        /// @notice Details of the variant.
        Variants variant;
        /// @notice Percentage chance to obtain variant upon purchase of base content.
        uint256 rarityPercentage;
    }

    /**
     * @title RSaleVariant23
     * @notice Stores information about multiple variant content-tokens associated RSale values.
     * @dev Defines variant details for RSale23-type.
     */
    struct RSaleVariant23 {
        Variants variant;
        uint256 rVal; // xx_xxxx_
    }

    /**
     * @title Collaborator
     * @notice Stores collaborator values of music tokens
     */
    struct Collaborator {
        address collaborator; // address of collaboratorAddress
        uint256 earningsContentSplit; // numerical split of total earnings they should recieve for each sale
    }

    struct DynamicSupply {
        uint256 initialSupply; // specific variant supply can be increased independently of one another
    } // is fixed release by default, can enable TIMED automatic release

    struct AutoRelease {
        uint256 numAudioBatchRelease; // += increases circulating supply, limit is totalSupply
        uint256 timeReleaseInterval; // specific date and time interval for each batch release
    }

    struct PreRelease {
        uint256 preReleaseReserve; // up to 10% of totalSupply || <= initialSupply
        uint256 preReleaseStart;
        uint256 pausedAt; // 0 by default, if < 0, correlates to timestamp when pause should occur
    }

    struct ArtistReserve {
        uint256 wavReserve; // Up to 30% totalSupply reservable for allocation through alternative means
        // IE: Live Event QR Code Reward, Future Airdrop Integration, etc.
    }

    /**
     * @notice Defined bit positions for MusicToken and sub-structs.
     * @dev These constants represent various properties and functionalities
     *      that can be enabled or disabled for a music token.
     */
    uint8 internal constant MUSIC_TOKEN__IS_COLLECTION = 0;
    uint8 internal constant IS_COLLECTION__SEPARATE_SALE_ALL = 1;
    uint8 internal constant IS_COLLECTION__SEPERATE_SALE_SPECIFIC = 2;
    uint8 internal constant SEPARATE_SALE__ENABLE_PRICE_TIERS = 3;
    uint8 internal constant MUSIC_TOKEN__IS_BONUS = 4;
    uint8 internal constant MUSIC_TOKEN__IS_EXCLUSIVE = 5;
    uint8 internal constant MUSIC_TOKEN__ENABLE_VARIANTS = 6;
    uint8 internal constant ENABLE_VARIANTS__RARITY_SALE = 7;
    uint8 internal constant RARITY_SALE__RSALE_2 = 16;
    uint8 internal constant RARITY_SALE__RSALE_3 = 17;
    uint8 internal constant MUSIC_TOKEN__ENABLE_VERSIONS = 8;
    uint8 internal constant MUSIC_TOKEN__OF_FUTURE_COLLECTION = 9;
    uint8 internal constant MUSIC_TOKEN__ENABLE_STEMS = 10;
    uint8 internal constant MUSIC_TOKEN__DYNAMIC_SUPPLY = 11;
    uint8 internal constant DYNAMIC_SUPPLY__AUTO_RELEASE = 12;
    uint8 internal constant MUSIC_TOKEN__ARTIST_RESERVE = 13;
    uint8 internal constant MUSIC_TOKEN__PRE_RELEASE = 14;
    uint8 internal constant MUSIC_TOKEN__HAS_COLLABORATORS = 15;

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
     * @notice Associates content hash to next chronologically available contentId position.
     * @dev Maps bytes32 hashId to an artist's next available contentId location, reserving it.
     */
    mapping(bytes32 hashId => uint256 reservedCollectionContentId)
        public s_ofFutureCollection;

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

    mapping(address artist => mapping(uint256 contentId => RSaleVariant))
        public s_rVariantIndex;

    mapping(uint256 rMap => RSaleVariant23) public s_rVariantIndex23;

    // rMap defines content (multi) rarity defs, rVal defines "what those defs are"
    /* ~First Val of rMap == collection (if collection) itself~ (notes to self)
    Album: 'TRAP' | Variants: 'Yes', NumVariants: '1', NumVariantAudio: '10' (VariantName == 'vTrap')
    vTrap (5 tiers of rarity) | rVal: ('001_20%', '010_10%', '100_5%', '110_1%', '011_0.005%', '000_N/A)
    vTrap (rMap): 000001010110011000100001010110000 (6 TOTAL POSSIBLE RARITIES + N/A rarity)

    */

    /**
     * @notice Stores STEM track information for each piece of content.
     * @dev Maps an artist's address and content ID to the track hash and STEM identifiers.
     */
    mapping(address => mapping(uint256 => mapping(bytes32 => uint8)))
        public s_stemTracks;

    /**
     * @notice Stores version information for each piece of content.
     * @dev Maps an artist's address and content ID to the version index and track identifier hash.
     */
    mapping(address => mapping(uint256 => mapping(uint8 => bytes32)))
        public s_songVersions;

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

    /**      *** To be refactored ***
     * @notice Retrieves the details of a music collection.
     * @dev This function is a view function that returns the details of a music collection.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the collection.
     */
    /*   function getCollectionDetails(
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
        MusicToken storage musicTokenDetails = s_musicTokens[_artistId][
            _contentId
        ];
        IndividualSale storage individualSaleDetails = s_individualSales[
            _artistId
        ][_contentId];

        // Prepare arrays for songContentIds and song prices
        songContentIds = new uint256[](musicTokenDetails.numAudio);
        songPrices = new uint256[](musicTokenDetails.numAudio);

        // Populate the arrays
        for (uint16 i = 0; i < musicTokenDetails.numAudio; i++) {
            songContentIds[i] = musicTokenDetails.songContentIds[i];
            songPrices[i] = individualSaleDetails.songPrices[i];
        }
    
        // Return the details of the specified music collection and individual sale details
        return (
            musicTokenDetails.numAudio,
            musicTokenDetails.enableIndividualSale,
            songContentIds,
            individualSaleDetails.enableSeperateSaleAll,
            songPrices
        );
    }
    */

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

    /**
     * @notice Generates a unique hash identifier for a specific track or version.
     * @dev Combines artist's address, content ID, variant number, audio number, and track version to generate a unique bytes32 hash.
     * @param _artistId The address of the artist.
     * @param _contentId The unique ID of the content.
     * @param _numVariant Variant index in published context of the content.
     * @param _numAudio The number of audio tracks in the content.
     * @param _trackVersion The version index of the track.
     * @return bytes32 The unique hash identifier for the track or version.
     */
    function generateContentHashId(
        address _artistId,
        uint256 _contentId,
        uint16 _numVariant,
        uint16 _numAudio,
        uint8 _trackVersion
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    _artistId,
                    _contentId,
                    _numVariant,
                    _numAudio,
                    _trackVersion
                )
            );
    }
}
