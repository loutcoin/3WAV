// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ContentTokenSearchStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

import {
    CContentTokenStorage
} from "../../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    NumericalConstants
} from "../../../../src/3WAVi__Helpers/NumericalConstants.sol";

library LibPublishCContentTokenSearchHelper {
    error LibPublishCContentTokenSearchHelper__InputInvalid();

    function _publishCContentTokenSearchHelper(
        bytes32 _hashId,
        CContentTokenStorage.CContentToken calldata _cContentToken
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        CContentTokenStorage.CContentToken calldata _cCTKN = _cContentToken;

        if (
            _cCTKN.numToken == 0 ||
            _cCTKN.cSupplyVal < NumericalConstants.MIN_CSUPPLY ||
            _cCTKN.cSupplyVal > NumericalConstants.MAX_CSUPPLY ||
            _cCTKN.sPriceUsdVal <
            NumericalConstants.MIN_ENCODED_SPRICE_USD_VAL ||
            _cCTKN.sPriceUsdVal >
            NumericalConstants.MAX_ENCODED_SPRICE_USD_VAL ||
            _cCTKN.cPriceUsdVal <
            NumericalConstants.MIN_ENCODED_CPRICE_USD_VAL ||
            _cCTKN.cPriceUsdVal >
            NumericalConstants.MAX_ENCODED_CPRICE_USD_VAL ||
            _cCTKN.sSupplyVal < NumericalConstants.MIN_SSUPPLY ||
            _cCTKN.sSupplyVal > NumericalConstants.MAX_SSUPPLY ||
            _cCTKN.sReserveVal < NumericalConstants.SHIFT_39__160 ||
            _cCTKN.sReserveVal > NumericalConstants.MAX_SRESERVE_VAL ||
            _cCTKN.cReleaseVal < NumericalConstants.SHIFT_19__96 ||
            _cCTKN.cReleaseVal > NumericalConstants.SHIFT_20__96
        ) {
            revert LibPublishCContentTokenSearchHelper__InputInvalid();
        }
        ContentTokenSearchStruct.s_cContentTokenSearch[
            _hashId
        ] = CContentTokenStorage.CContentToken({
            numToken: _cCTKN.numToken,
            cSupplyVal: _cCTKN.cSupplyVal,
            sPriceUsdVal: _cCTKN.sPriceUsdVal,
            cPriceUsdVal: _cCTKN.cPriceUsdVal,
            sSupplyVal: _cCTKN.sSupplyVal,
            sReserveVal: _cCTKN.sReserveVal,
            cReleaseVal: _cCTKN.cReleaseVal
        });
    }
}
