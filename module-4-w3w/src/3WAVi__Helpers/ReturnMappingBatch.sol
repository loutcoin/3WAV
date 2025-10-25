// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// ContentToken
import {ContentTokenSearchStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenSearchStorage.sol";
//import {ContentTokenPriceMapStorage} from "../../src/Diamond__Storage/ContentToken/ContentTokenPriceMapStorage.sol";

library ReturnMappingBatch {
    // limitation, requires all hashId to be of sContentToken type or else will return '0' at index[x]
    // Function needs modification to be correctly implemented,
    // Is not incorporated into greater system is likely to be deprecated
    /*function returnSContentTokenPriceUsdValBatch(
        bytes32[] calldata _hashIdBatch
    ) internal returns (uint32[] memory _priceUsdValBatch) {
        uint32 _priceLength = uint32(_hashIdBatch.length);
        _priceUsdValBatch = new uint32[](_priceLength);

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        for (uint32 i = 0; i < _priceLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint32 _priceUsd = ContentTokenSearchStruct
                .s_sContentTokenSearch[_hashId]
                .priceUsdVal;
        }
    }*/
    // limitation, requires all hashId to be of cContentToken type or else will return '0' at index[x]
    // Function needs modification to be correctly implemented,
    // Is not incorporated into greater system is likely to be deprecated
    /*function returnCContentTokenPriceUsdValBatch(
        bytes32[] calldata _hashIdBatch
    ) internal returns (uint112[] memory _priceUsdValBatch) {
        uint112 _priceLength = _hashIdBatch.length;
        _priceUsdValBatch = new uint112[](_priceLength);

        ContentTokenSearchStorage.ContentTokenSearch
            storage ContentTokenSearchStruct = ContentTokenSearchStorage
                .contentTokenSearchStorage();
        for (uint112 i = 0; i < _priceLength; ) {
            _priceUsdValBatch = ContentTokenSearchStruct
                .s_cContentTokenSearch[_hashIdBatch[i]]
                .sPriceUsdVal;
            if (priceUsdVal == 0) {
                _priceUsdValBatch = ContentTokenSearchStruct
                    .s_cContentTokenSearch[_hashIdBatch[i]]
                    .cPriceUsdVal;
            }
        }
    }*/
}
