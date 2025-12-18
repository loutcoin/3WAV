// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {
    ContentTokenSupplyMapStorage
} from "../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";
import {LibFeed} from "../../../../src/3WAVi__Helpers/FacetHelpers/LibFeed.sol";
import {
    LibWavSupplies
} from "../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/LibWavSupplies.sol";
import {
    Binary2BitDBC
} from "../../../../src/3WAVi__Helpers/DBC/Binary2BitDBC.sol";
import {PriceDBC} from "../../../../src/3WAVi__Helpers/DBC/PriceDBC.sol";
import {
    ReturnContentToken
} from "../../../../src/3WAVi__Helpers/ReturnMapping/ReturnContentToken.sol";
import {
    ReturnMapMapping
} from "../../../../src/3WAVi__Helpers/ReturnMapping/ReturnMapMapping.sol";

import {
    WavSaleToken
} from "../../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

library ValidateWavSaleBatch {
    event testA(bool _success);
    event test2(bool _success);
    event test3(bool _success);

    error ValidateWavSaleBatch__LengthValIssue();
    error ValidateWavSaleBatch__InputError404();

    /*
     * @notice Validates dynamic quantity of price properties, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data batch prior to sale.
     *      Function Selector: 0x83b2de3d
     * @param _hashIdBatch Batch of Content Token identifier values being queried.
     * @param _numTokenBatch Batch of Content Token identifiers used to specify the token index being queried.
     * @param _quantityBatch Total instances of each numToken.
     */
    /*function _validateDebitWavStoreBatch(
        bytes32[] calldata _hashIdBatch,
        uint16[] calldata _numTokenBatch,
        uint112[] calldata _quantityBatch
    ) internal returns (uint256[] memory _weiPrice) {
        uint256 _hashLength = _hashIdBatch.length;
        if (
            _hashLength == 0 ||
            _hashLength != _numTokenBatch.length ||
            _hashLength != _quantityBatch.length
        ) {
            revert ValidateWavSale__LengthValIssue();
        }

        _weiPrice = new uint256[](_hashLength);

        for (uint256 i = 0; i < _hashLength; ) {
            bytes32 _hashId = _hashIdBatch[i];
            uint16 _numToken = _numTokenBatch[i];
            uint112 _quantity = _quantityBatch[i];

            // Branch 1: SContentToken priceUsdVal
            uint32 _cPriceUsd = ReturnContentToken
                .returnSContentTokenPriceUsdVal(_hashId);
            if (_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(
                    _cPriceUsd
                );
                LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
                _weiPrice[i] = LibFeed._usdToWei(uint256(_cPriceUsdVal));
                unchecked {
                    ++i;
                }
                continue;
            }

            // Branch 2: CContentToken cPriceUsdVal
            _cPriceUsd = ReturnContentToken.returnCContentTokenCPriceUsdVal(
                _hashId
            );
            if (_cPriceUsd == 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(
                    _cPriceUsd
                );
                LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
                _weiPrice[i] = LibFeed._usdToWei(uint256(_cPriceUsdVal));
                unchecked {
                    ++i;
                }
                continue;
            }

            // Branch 3: CContentToken sPriceUsdVal
            uint112 _sPriceUsdVal = ReturnContentToken
                .returnCContentTokenSPriceUsdVal(_hashId);
            if (_sPriceUsdVal != 0 && _numToken != 0) {
                /*uint256 _priceMap = ReturnContentToken
                    .returnCContentTokenPriceMap(_hashId);*/
    /*uint16 _pages = uint16((uint256(_numToken) + 63) >> 6);

                uint256 _priceMap = ReturnMapMapping.returnSPriceMap(
                    _hashId,
                    _pages
                );

                uint8 _priceState = Binary2BitDBC._decode2BitState(
                    _priceMap,
                    _numToken
                );
                uint256 _usdPrice = PriceDBC._sPriceUsdValState(
                    _priceState,
                    _sPriceUsdVal
                );

                ContentTokenSupplyMapStorage.ContentTokenSupplyMap
                    storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                        .contentTokenSupplyMapStorage();

                //uint8 _tierId = LibWavSupplies._getTier(_hashId, _numToken);
                uint16 _wordIndex = _numToken >> 6;
                uint8 _within = uint8(_numToken & 63);

                uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                    _hashId
                ][_wordIndex];
                uint256 _shift = uint256(_within) * 4;
                uint8 _tierId = uint8((_packed >> _shift) & 0xF);
                // wasn't originally type-cast but sDebitWavStoreSupply expects uint112
                // are other ways to address this if needed
                // sDebitWavStoreSupply could take uint256 quantity and it could be typecasted into mapping
                LibWavSupplies.sDebitWavStoreSupply(
                    _hashId,
                    _tierId,
                    _quantity
                );

                // (reminder for testing) _weiPrice was previously different undeclared identifier
                _weiPrice[i] = LibFeed._usdToWei(_usdPrice);
                unchecked {
                    ++i;
                }
                continue;
            }
            revert ValidateWavSale__InputError404();
        }
    }*/

    /**
     * @notice Validates dynamic quantity of price properties, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data batch prior to sale.
     *      Function Selector:
     * @param _wavSaleToken User-defined batch of WavSaleToken structs.
     */
    function _validateDebitWavStoreBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) internal returns (uint256[] memory _weiPrice) {
        if (_wavSaleToken.length == 0) {
            revert ValidateWavSaleBatch__LengthValIssue();
        }

        _weiPrice = new uint256[](_wavSaleToken.length);

        for (uint256 i = 0; i < _wavSaleToken.length; ++i) {
            bytes32 _hashId = _wavSaleToken[i].hashId;
            uint16 _numToken = _wavSaleToken[i].numToken;
            uint112 _quantity = _wavSaleToken[i].purchaseQuantity;
            // Branch 1: SContentToken priceUsdVal
            uint32 _cPriceUsd = ReturnContentToken
                .returnSContentTokenPriceUsdVal(_hashId);
            if (_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(
                    _cPriceUsd
                );
                LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
                _weiPrice[i] = LibFeed._usdToWei(uint256(_cPriceUsdVal));
                /*unchecked {
                    ++i;
                }
                continue;*/
            } // _creatorTokenVariant[i].creatorToken.creatorId
            // bytes32 _hashId = _creatorToken[i].hashId;

            // Branch 2: CContentToken cPriceUsdVal
            _cPriceUsd = ReturnContentToken.returnCContentTokenCPriceUsdVal(
                _hashId
            );
            if (_cPriceUsd != 0 && _numToken == 0) {
                uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(
                    _cPriceUsd
                );
                LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
                _weiPrice[i] = LibFeed._usdToWei(uint256(_cPriceUsdVal));
                /*unchecked {
                    ++i;
                }
                continue;*/
            }

            // Branch 3: CContentToken sPriceUsdVal
            uint112 _sPriceUsdVal = ReturnContentToken
                .returnCContentTokenSPriceUsdVal(_hashId);
            if (_sPriceUsdVal != 0 && _numToken != 0) {
                /*uint256 _priceMap = ReturnContentToken
                    .returnCContentTokenPriceMap(_hashId);*/
                uint16 _pages = uint16((uint256(_numToken) + 63) >> 6);

                uint256 _priceMap = ReturnMapMapping.returnSPriceMap(
                    _hashId,
                    _pages
                );

                uint8 _priceState = Binary2BitDBC._decode2BitState(
                    _priceMap,
                    _numToken
                );
                uint256 _usdPrice = PriceDBC._sPriceUsdValState(
                    _priceState,
                    _sPriceUsdVal
                );

                ContentTokenSupplyMapStorage.ContentTokenSupplyMap
                    storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                        .contentTokenSupplyMapStorage();

                //uint8 _tierId = LibWavSupplies._getTier(_hashId, _numToken);
                {
                    uint16 _wordIndex = _numToken >> 6;
                    uint8 _within = uint8(_numToken & 63);

                    uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                        _hashId
                    ][_wordIndex];
                    uint256 _shift = uint256(_within) * 4;
                    uint8 _tierId = uint8((_packed >> _shift) & 0xF);
                    // wasn't originally type-cast but sDebitWavStoreSupply expects uint112
                    // are other ways to address this if needed
                    // sDebitWavStoreSupply could take uint256 quantity and it could be typecasted into mapping
                    LibWavSupplies.sDebitWavStoreSupply(
                        _hashId,
                        _tierId,
                        _quantity
                    );
                }

                // (reminder for testing) _weiPrice was previously different undeclared identifier
                _weiPrice[i] = LibFeed._usdToWei(_usdPrice);
                /*unchecked {
                    ++i;
                }
                continue;*/
            }
            if (_weiPrice[i] == 0) {
                if (
                    ReturnContentToken.returnSContentTokenPriceUsdVal(
                        _hashId
                    ) ==
                    0 &&
                    ReturnContentToken.returnCContentTokenCPriceUsdVal(
                        _hashId
                    ) ==
                    0 &&
                    ReturnContentToken.returnCContentTokenSPriceUsdVal(
                        _hashId
                    ) ==
                    0
                ) {
                    revert ValidateWavSaleBatch__InputError404();
                }
            }
        }
    }
}
