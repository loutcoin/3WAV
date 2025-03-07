// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {WavRoot} from "../src/WavRoot.sol";
import {SContentTokenStorage} from "../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";
import {CContentTokenStorage} from "../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";
import {ContentTokenPriceMapStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenPriceMapStorage.sol";
import {ContentTokenSearchStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
import {ContentTokenFlagStorage} from "../src/Diamond__Storage/ContentToken/ContentTokenFlagStorage.sol";
// Optionals:
import {CollaboratorStructStorage} from "../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";
import {InAssociationStorage} from "../src/Diamond__Storage/ContentToken/Optionals/InAssociationStorage.sol";
import {VariantMapStorage} from "../src/Diamond__Storage/ContentToken/Optionals/VariantMapStorage.sol";
import {VariantStructStorage} from "../src/Diamond__Storage/ContentToken/Optionals/VariantStructStorage.sol";
import {VariantStemStorage} from "../src/Diamond__Storage/ContentToken/Optionals/VersionStemStorage.sol";
// CreatorToken:
import {CreatorTokenStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {CreatorTokenMapStorage} from "../src/Diamond__Storage/CreatorToken/CreatorTokenMapStorage.sol";
// AuthorizedAddr:
import {AuthorizedAddrs} from "../src/Diamond__Storage/ActiveAddresses/AuthorizedAddrs.sol";

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
    error WavToken__IsNotLout();
    error WavToken__CollaboratorSplitLengthMismatch();
    error WavToken__IsNotCollection();
    error WavToken__BitmapOverflow();
    error WavToken__RSaleMismatch();
    error WavToken__RSaleOverflow();

    //ONLY things directly relevant to our coure collection and or individual tokens within it
    //IE: price tiers, total supply and possible total supply tiers / initial supply tiers for indv content tokens == okay
    // WavReserve/PreRelease should only be present in SupplyVal as %
    // :) Everything except for totalSupply and initalSupply should be % to save space lol (math checks out, 72 digits)

    // compaction refactors // ContentToken AutoRelease
    struct SContentToken {
        // *SLOT 1*
        uint24 numToken;
        uint32 priceUsdVal; // 0B primary_priceInUsd
        uint104 supplyVal; // 0B *initial*totalSupply[0], | 2B wav*Pre*Reserve[2]
        uint96 releaseVal; // 0B standard/Start, | 2B end[2] | 3B preStart*pauseAt*[3]
        // *SLOT 2*
        uint256 bitVal;
    } // max uint256 ~75 digits

    // ********* priceUsdVal *********:
    /**$ ~Max Primary <999,999.99
    - 0B-A: primary[1] (uniform in any case) | 

    - 1B-A: primary[1], standard[0] (uniform, no 0Val),
    - 1B-B: primary[1], firstShare[0]
    - 1B-C: primary[1], disabled[0] (uniform primary, unusual) |

    - 2B-A: primary[10], standard[01], disabled[00] (only "3-states" possibility (1))
    - 2B-B  primary[10], firstSplit[11], standard[01]  (only "3-states" possibility (2))
    - 2B-C: primary[10], firstSplit[11], secondShare[01]  (only "3-states" possibility (3))
    - 2B-D: primary[10], firstSplit[11], secondShare[01], thirdSplit[00] 
    - 2B-E: primary[10], firstSplit[11], standard[01], disabled[00]
    - 2B-F: primary[10], firstSplit[11], standard[01], disabled[00]
    - 2B-G: primary[10], firstSplit[11], secondSplit[01], disabled[00] 
    - 2B-H: primary[10], standard[01], accessible[00], exclusive[11] |
   
    - 3B-A: primary[100], standard[010], accessible[001], exclusive[101], disabled[000] (only "5-states" possibility (1))
    - 3B-B: primary[100], firstSplit[110], standard[010], accessible[001], exclusive[101] (only "5-states" possibility (2))
    - 3B-C: primary[100], firstSplit[110], secondSplit[011], ThirdSplit[111], standard[010] (only "5-states" possibility (3))
    - 3B-D: primary[100], firstSplit[110], standard[010], accessible[001], exclusive[101] disabled[000] (only "6-states" possibility (1))
    - 3B-E: primary[100], firstSplit[110], secondSplit[011], standard[010], accessible[001], exclusive[101] disabled[000] (only "7-states" possibility (1))
    - 3B-F: primary[100], firstSplit[110], secondSplit[011], thirdSplit[111], standard[010], accessible[001], exclusive[101] disabled[000]  
    ---------
    **** Formality ****: 
    -Primary- [1/10/100] 
    -   "Always first value. Always non-zero value. Always leading '1' followed by zero's dependant on bit-system"  
    - -
    -0Val/Disabled- [0/00/000] 
    -   "Always '0' if present"                                                                                  
    - -
    -Standard- [0/01/010]
    -   "May be assigned in absence of price tiers to seperate sale content tokens."
    - -
    -Accessible- [00/001]
    -   "1/2 optionally additional price tiers. Defined value must be less than defined 'Standard' value.
    - -
    -Exclusive- [11/101]
    -   "1/2 optionally additional price tiers. Defined value must be greater than defined 'Standard' value.
    - - 
    -firstSplit- [0/11/110]
    -
    - -
    -secondSplit- [01/011]
    -
    - -
    -thirdSplit- [00/111]
    ------------------
    // ********* releaseVal *********:
    - 0B-A: standard/Start[1]
    - 0B-B  End/Disabled/Undefined[0] (if token doesn't have absolute release date)

    - 1B-A: standard/Start[1], End/Disabled/Undefined[0]

    ---------
    -standard/Start- [1/10/100]
    -0Val/Disabled- [0/00/000]
    */

    struct CContentToken {
        // *SLOT 1*
        uint24 numToken;
        uint104 cSupplyVal; // cTotalSupply, cInitialSupply, cWavR, cPreSaleR
        uint112 sPriceUsdVal; // standard_indv[10], | 2B accessible_indv[01], exclusive_indv[11]
        // *SLOT 2*
        uint32 cPriceUsdVal;
        uint112 sTotalSupply;
        uint112 sInitialSupply;
        // *SLOT 3*
        uint80 sWavR;
        uint80 sPreSaleR;
        uint96 cReleaseVal;
        // *SLOT 4*
        uint256 bitVal;
    }

    /*
     uint112 sTotalSupply
     uint112 sInitialSupply
     uint32 cPriceUsdVal 
    // SLOT (256 bits / 32 bytes)

    */
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
     * @notice Stores information about multiple variant content-tokens associated RSale values.
     * @dev Defines details for RSale type variant(s).
     */
    struct RSaleVariant {
        Variants variant;
        uint256 rVal; // xx_xxxx_
    }

    // only 3 split tiers, infinite possible collaborators
    // string compacted collaborator earning split ID
    /**
     * @title Collaborator
     * @notice Stores collaborator values of music tokens
     */
    struct Collaborator {
        string collaboratorVal;
        uint256 revenueShareVal; // numerical split of total earnings they should recieve for each sale
        // collaboratorhexidval
        // contentdualcollaboratorhexvalsplitvalbitmap
    }

    // Was Dynamic* specific variant supply can be increased independently of one another
    // is fixed release by default, can enable TIMED automatic release

    struct AutoRelease {
        uint128 numAudioBatchRelease; // += increases circulating supply, limit is totalSupply
        uint128 timeReleaseInterval; // specific date and time interval for each batch release
    }

    //preSale pause 0 by default, if < 0, correlates to timestamp when pause should occur

    // Was WavReserve Up to 30% totalSupply reservable for allocation through alternative means
    // IE: Live Event QR Code Reward, Future Airdrop Integration, etc.

    /**
     * @notice Defined 3-bit functional flag system for ContentToken functionality.
     * @dev These constants represent various functional flag-states
     *      and dynamic bit-system data implementations for various enabled/disabled ContentToken functionality.
     */
    uint8 internal constant MUSIC_TOKEN__TOKEN_TYPE__TYP = 0; // Collection, Single
    uint8 internal constant MUSIC_TOKEN__SPECIAL__TYP = 1; // Bonus, OFC, OFCereal
    uint8 internal constant MUSIC_TOKEN__COLLABORATORS__TYP = 2; // Disabled, Enabled...<More interesting collab encouragement in future!>

    uint8 internal constant COLLECTION__SEPERATE_SALE__SAL = 3; // Disabled, All, Specific, All/PriceTiers, Specific/PriceTiers
    uint8 internal constant MUSIC_TOKEN__SPECIAL_SALE__SAL = 4; // Disabled, Limited, Rarity

    uint8 internal constant MUSIC_TOKEN__RESERVES__SPY = 5; // Disabled, Wav, Pre, Wav/Pre, WavTiers, PreTiers, WavPreTiers
    uint8 internal constant MUSIC_TOKEN__DYNAMIC_SUPPLY_SPY = 6; // Disabled, INIT, INIT/AUTOR, | SINGLETIERS/SPECIFIC/ALL, AUTORTIERS/SPECIFIC/ALL, SUPTIERS/AUTORTIERS/SPECIFIC/ALL

    uint8 internal constant MUSIC_TOKEN__VARIANTS_VERSIONS__XTR = 7;
    uint8 internal constant MUSIC_TOKEN__IE_STEMS__XTR = 8;

    /**
     * @notice Stores details about 'collection' tokens, including supply, price, and features.
     * @dev Maps an artist's address and content ID to the MusicToken struct.
     */
    mapping(bytes32 hashId => CContentToken) public s_contentTokens;

    /**
     * @notice Stores details about each 'single' tokens, including supply, price, and features.
     * @dev Maps an artist's address and content ID to the MusicToken struct.
     */
    mapping(bytes32 hashId => SContentToken) public s_sContentTokens;

    /**
     *@notice Stores information regarding allocation of artist and fan music token reserves
     *@dev Maps an artist's address and content ID to the ArtistReserve struct
     Was WavReserve Replace with helpful getter functions*/

    /**
     * @notice Stores information about collaborators for each piece of music.
     * @dev Maps an artist's address, content ID, and collaborator index to the Collaborator struct.
     */
    mapping(address => mapping(uint256 => Collaborator)) public s_collaborators;

    /**
     * @notice Stores information about the supply of each song within a collection.
     * @dev Maps an artist's address and content ID to the DynamicSupply struct.
     was DynamicSupply */

    /**
     * @notice Associates content hash to next chronologically available contentId position.
     * @dev Maps bytes32 hashId to an artist's next available contentId location, reserving it.
     */
    mapping(bytes32 hashId => uint256 reservedCollectionContentId)
        public s_ofFutureCollection;

    /**
     * @notice Stores information about the prices of individual songs within a collection.
     * @dev Maps a single or collection's hashId to a sale state bitmap.
     */
    mapping(bytes32 hashId => uint256 priceMap) public s_contentPrice;

    /**
     * @notice Stores information about variants of the music tokens.
     * @dev Maps an artist's address and content ID to the MusicTokenVariants struct.
     */

    mapping(address artist => mapping(uint256 contentId => RSaleVariant))
        public s_rVariantIndex;

    mapping(uint256 rMap => RSaleVariant) public s_rVariantIndex23;

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
     * @dev Maps an artist's address and content ID to the version index.
     */ // modified to bytes32 in Diamond
    mapping(address => mapping(uint256 => uint8)) public s_songVersions;

    function publishWavSingle(
        bytes32 _hashId,
        CreatorToken memory _creatorToken,
        MusicToken memory _contentToken
    ) public {
        if (s_authorizedAddr[msg.sender] != true) {
            revert WavToken__IsNotLout();
        }
        s_publishedToken[_hashId] = _creatorToken;
        s_contentTokens[_hashId] = _contentToken;
    }
    // if true needs to access single instance of Variant-type struct and or Collaborator struct as well still

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
    ) external pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    _artistId,
                    _contentId,
                    _numVariant,
                    _numAudio,
                    _trackVersion
                )
            );
    }
} /*  CreatorToken memory CRTK = new CreatorToken({
            creatorId: _creatorId,
            contentId: _contentId,
            isOwner: true
        });
        s_musicFiles[_hashId] = WTKN;

        MusicToken MTKN = new MusicToken({
            supplyVal: _supplyVal,
            priceVal: _priceVal,
            releaseVal: _releaseVal,
            numAudio: _numAudio,
            bitVal: _bitVal
        });
        s_musicTokens[_hashId] = MTKN; */
