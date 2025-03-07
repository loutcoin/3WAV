// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library ContentTokenFlagStorage {
    /**
     * @notice Defined 3-bit functional flag system for ContentToken functionality.
     * @dev These constants represent various functional flag-states
     *      and dynamic bit-system data implementations for various enabled/disabled ContentToken functionality.
     */
    uint8 internal constant MUSIC_TOKEN__TOKEN_TYPE__TYP = 0; // Collection, Single
    uint8 internal constant MUSIC_TOKEN__SPECIAL__TYP = 1; // Bonus, OFC, OFCereal
    uint8 internal constant MUSIC_TOKEN__COLLABORATORS__TYP = 2; // Disabled, Enabled...<More interesting collab encouragement in future!>

    uint8 internal constant COLLECTION__SEPERATE_SALE__SAL = 3; // Disabled, All, Specific, All/PriceTiers, Specific/PriceTiers
    uint8 internal constant MUSIC_TOKEN__SPECIAL_SALE__SAL = 4; // Disabled, Limited, Rarity %dc

    uint8 internal constant MUSIC_TOKEN__RESERVES__SPY = 5; // Disabled, Wav, Pre, Wav/Pre, WavTiers, PreTiers, WavPreTiers
    uint8 internal constant MUSIC_TOKEN__DYNAMIC_SUPPLY_SPY = 6; // Disabled, INIT, INIT/AUTOR, | SINGLETIERS/SPECIFIC/ALL, AUTORTIERS/SPECIFIC/ALL, SUPTIERS/AUTORTIERS/SPECIFIC/ALL

    uint8 internal constant MUSIC_TOKEN__VARIANTS_VERSIONS__XTR = 7;
    uint8 internal constant MUSIC_TOKEN__IE_STEMS__XTR = 8;
}
