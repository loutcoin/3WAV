// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSearchStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    NumericalConstants
} from "../../../src/3WAVi__Helpers/NumericalConstants.sol";

library LibPublishSContentTokenSearchHelper {
    error LibPublishSContentTokenSearchHelper__InputInvalid();

    function _publishSContentTokenSearchHelper(
        bytes32 _hashId,
        SContentTokenStorage.SContentToken calldata _sContentToken
    ) internal {
        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();

        SContentTokenStorage.SContentToken calldata _sCTKN = _sContentToken;

        if (
            _sCTKN.numToken == 0 ||
            _sCTKN.priceUsdVal <
            NumericalConstants.MIN_ENCODED_CPRICE_USD_VAL ||
            _sCTKN.priceUsdVal >
            NumericalConstants.MAX_ENCODED_CPRICE_USD_VAL ||
            _sCTKN.supplyVal < NumericalConstants.MIN_CSUPPLY ||
            _sCTKN.supplyVal > NumericalConstants.MAX_CSUPPLY
        ) {
            revert LibPublishSContentTokenSearchHelper__InputInvalid();
        }

        ContentTokenSearchStruct.s_sContentTokenSearch[
            _hashId
        ] = SContentTokenStorage.SContentToken({
            numToken: _sCTKN.numToken,
            priceUsdVal: _sCTKN.priceUsdVal,
            supplyVal: _sCTKN.supplyVal,
            releaseVal: _sCTKN.releaseVal
        });
    }
}
