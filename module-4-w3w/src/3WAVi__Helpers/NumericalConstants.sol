// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library NumericalConstants {
    uint96 internal constant SECOND_TO_HOUR_PRECISION = 3600;

    uint96 internal constant CRELEASE_6_MAX = 1000000;

    uint112 internal constant CPRE_SUPPLY_MAXIMUM = 400000;

    uint80 internal constant PRE_SUPPLY_MAX__80 = 400000;

    /// Used in cPriceUsdValEncoder
    uint32 internal constant LEADING_TEN__THIRTY_TWO_BIT = 1000000000;

    /// Used in cPriceUsdValDecoder
    uint32 internal constant MIN_ENCODED_CPRICE_USD_VAL = 1000000001;

    uint32 internal constant MAX_ENCODED_CPRICE_USD_VAL = 1999999999;

    /// Used in sPriceUsdValDecoder
    uint112 internal constant MIN_ENCODED_SPRICE_USD_VAL =
        100000000001000000000000000000;

    uint112 internal constant MAX_ENCODED_SPRICE_USD_VAL =
        101999999998999999997999999999;

    uint112 internal constant MIN_STOTAL = 100000000000100000000000000000000;

    uint112 internal constant MIN_REMAINING_SUPPLY =
        1000000000100000000000000000000;

    uint112 internal constant MIN_CSUPPLY = 100000000010000000000000000000000;

    uint112 internal constant MAX_CSUPPLY = 199999999999999999999999999000001;

    uint128 internal constant MIN_ENCODED_ROYALTY =
        100000001000000000000000000000000000000;

    // 100_999999_999999_999999_000001_000001_000001
    uint160 internal constant MAX_SRESERVE_VAL =
        100999999999999999999000001000001000001;

    uint224 internal constant MIN_SSUPPLY =
        100000000000100000000000000000000000000000000000000000000000000;

    //100_9999999999_9999999999_9999999999_9999999999_9999999999_9999999999
    uint224 internal constant MAX_SSUPPLY =
        100999999999999999999999999999999999999999999999999999999999999;

    uint96 internal constant SHIFT_1__96 = 10 ** 1;

    uint96 internal constant SHIFT_7__32 = 10 ** 6;

    uint80 internal constant SHIFT_7__80 = 10 ** 6;

    uint96 internal constant SHIFT_7__96 = 10 ** 6;

    uint112 internal constant SHIFT_7 = 10 ** 6;

    uint160 internal constant SHIFT_7__160 = 10 ** 6;

    uint96 internal constant SHIFT_8__96 = 10 ** 7;

    uint112 internal constant SHIFT_10 = 10 ** 9;

    uint112 internal constant SHIFT_11 = 10 ** 10;

    uint224 internal constant SHIFT_11__224 = 10 ** 10;

    uint80 internal constant SHIFT_13__80 = 10 ** 12;

    uint96 internal constant SHIFT_13__96 = 10 ** 12;

    uint112 internal constant SHIFT_13 = 10 ** 12;

    uint160 internal constant SHIFT_13__160 = 10 ** 12;

    // ******* ******
    uint96 internal constant SHIFT_14__96 = 10 ** 13;

    uint80 internal constant SHIFT_19__80 = 10 ** 18;

    uint96 internal constant SHIFT_19__96 = 10 ** 18;

    uint112 internal constant SHIFT_19 = 10 ** 18;

    uint160 internal constant SHIFT_19__160 = 10 ** 18;

    uint80 internal constant SHIFT_21__80 = 10 ** 20;

    uint96 internal constant SHIFT_20__96 = 10 ** 19;

    uint112 internal constant SHIFT_21 = 10 ** 20;

    uint224 internal constant SHIFT_21__224 = 10 ** 20;

    uint112 internal constant SHIFT_23 = 10 ** 22;

    uint160 internal constant SHIFT_25__160 = 10 ** 24;

    uint112 internal constant SHIFT_28 = 10 ** 27;

    uint112 internal constant SHIFT_30 = 10 ** 29;

    uint112 internal constant SHIFT_31 = 10 ** 30;

    uint160 internal constant SHIFT_31__160 = 10 ** 30;

    uint224 internal constant SHIFT_31__224 = 10 ** 30;

    uint112 internal constant SHIFT_33 = 10 ** 32;

    //uint112 internal constant SHIFT_34 = 10 ** 33;

    uint160 internal constant SHIFT_37__160 = 10 ** 36;

    uint160 internal constant SHIFT_39__160 = 10 ** 38;

    uint224 internal constant SHIFT_41__224 = 10 ** 40;

    uint224 internal constant SHIFT_51__224 = 10 ** 50;

    uint224 internal constant SHIFT_61__224 = 10 ** 60;

    uint224 internal constant SHIFT_63__224 = 10 ** 62;

    //uint224 internal constant SHIFT_64__224 = 10 ** 63;
}
