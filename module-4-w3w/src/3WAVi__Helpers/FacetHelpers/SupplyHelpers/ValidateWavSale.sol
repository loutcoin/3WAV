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

library ValidateWavSale {
    error ValidateWavSale__InputError404();
    /*
     * @notice Validates price property, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data prior to sale.
     *      Function Selector: 0x6e1da822
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    /*function _validateDebitWavStore(
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _quantity
    ) internal returns (uint256) {
        // _cPriceUsd = <x> encoded value found in sContentToken mapping
        uint32 _cPriceUsd = ReturnMapping.returnSContentTokenPriceUsdVal(
            _hashId
        );

        // if <x> value is found and exists...
        if (_cPriceUsd != 0 && _numToken == 0) {
            // Decode <x> encoded value
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
            return LibFeed.usdToWei(uint256(_cPriceUsdVal));
        }

        _cPriceUsd = ReturnMapping.returnCContentTokenCPriceUsdVal(_hashId);

        if (_cPriceUsd != 0 && _numToken == 0) {
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
            return LibFeed.usdToWei(uint256(_cPriceUsdVal));
        }

        // If returned sPriceUsdVal of hashId != 0...
        uint112 _sPriceUsdVal = ReturnMapping.returnCContentTokenSPriceUsdVal(
            _hashId
        );

        if (_sPriceUsdVal != 0 && _numToken != 0) {
            //if(!tokenEnabledState(_hashId, _numToken)) ***tokenEnabledState currently deprecated
            //revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            // ***** Needs to be able to return <x> page based on numToken
            uint256 _priceMap = ReturnMapping.returnSPriceMap(_hashId, 0);
            uint8 _priceState = Binary2BitDBC._decode2BitState(
                _priceMap,
                _numToken
            );
            uint256 _usdPrice = PriceDBC._sPriceUsdValState(
                _priceState,
                _sPriceUsdVal,
                _hashId
            );

            // debit tier pre-release supply
            uint8 _tierId = LibWavSupplies_getTier(_hashId, _numToken);
            LibWavSupplies.sDebitWavStoreSupply(_hashId, _tierId, _quantity);

            return LibFeed.usdToWei(_usdPrice);
        }

        revert ValidateWavSale__InputError404();
    }*/

    /*
     * @notice Validates price property, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data prior to sale.
     *      Function Selector: 0x6e1da822
     * @param _hashId Identifier of Content Token being queried.
     * @param _numToken Content Token identifier used to specify the token index being queried.
     * @param _quantity Value being deducted from relevant remaining supply source.
     */
    /*function _validateDebitWavStore(
        bytes32 _hashId,
        uint16 _numToken,
        uint112 _quantity
    ) internal returns (uint256) {
        // _cPriceUsd = <x> encoded value found in sContentToken mapping
        uint32 _cPriceUsd = ReturnContentToken.returnSContentTokenPriceUsdVal(
            _hashId
        );

        // if <x> value is found and exists...
        if (_cPriceUsd != 0 && _numToken == 0) {
            // Decode <x> encoded value
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
            return LibFeed._usdToWei(uint256(_cPriceUsdVal));
        }

        _cPriceUsd = ReturnContentToken.returnCContentTokenCPriceUsdVal(
            _hashId
        );

        if (_cPriceUsd != 0 && _numToken == 0) {
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(_hashId, _quantity);
            return LibFeed._usdToWei(uint256(_cPriceUsdVal));
        }

        // If returned sPriceUsdVal of hashId != 0...
        uint112 _sPriceUsdVal = ReturnContentToken
            .returnCContentTokenSPriceUsdVal(_hashId);

        if (_sPriceUsdVal != 0 && _numToken != 0) {
            //if(!tokenEnabledState(_hashId, _numToken)) ***tokenEnabledState currently deprecated
            //revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            // ***** Needs to be able to return <x> page based on numToken
            //uint256 _priceMap = ReturnContentToken.returnSPriceMap(_hashId, 0);
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

            // debit tier pre-release supply
            uint16 _wordIndex = _numToken >> 6;
            uint8 _within = uint8(_numToken & 63);

            uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[_hashId][
                _wordIndex
            ];
            uint256 _shift = uint256(_within) * 4;
            uint8 _tierId = uint8((_packed >> _shift) & 0xF);
            LibWavSupplies.sDebitWavStoreSupply(_hashId, _tierId, _quantity);

            return LibFeed._usdToWei(_usdPrice);
        }

        revert ValidateWavSale__InputError404();
    }*/

    /**
     * @notice Validates price property, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data prior to sale.
     *      Function Selector:
     * @param _wavSaleToken User-defined WavSale struct.
     */
    function _validateDebitWavStore(
        WavSaleToken.WavSale calldata _wavSaleToken
    ) internal returns (uint256) {
        // _cPriceUsd = <x> encoded value found in sContentToken mapping
        uint32 _cPriceUsd = ReturnContentToken.returnSContentTokenPriceUsdVal(
            _wavSaleToken.hashId
        );

        // if <x> value is found and exists...
        if (_cPriceUsd != 0 && _wavSaleToken.numToken == 0) {
            // Decode <x> encoded value
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(
                _wavSaleToken.hashId,
                _wavSaleToken.purchaseQuantity
            );

            return LibFeed._usdToWei(uint256(_cPriceUsdVal));
        }

        _cPriceUsd = ReturnContentToken.returnCContentTokenCPriceUsdVal(
            _wavSaleToken.hashId
        );

        if (_cPriceUsd != 0 && _wavSaleToken.numToken == 0) {
            uint32 _cPriceUsdVal = PriceDBC._cPriceUsdValDecoder(_cPriceUsd);
            LibWavSupplies.cDebitWavStoreSupply(
                _wavSaleToken.hashId,
                _wavSaleToken.purchaseQuantity
            );

            return LibFeed._usdToWei(uint256(_cPriceUsdVal));
        }

        // If returned sPriceUsdVal of hashId != 0...
        uint112 _sPriceUsdVal = ReturnContentToken
            .returnCContentTokenSPriceUsdVal(_wavSaleToken.hashId);

        if (_sPriceUsdVal != 0 && _wavSaleToken.numToken != 0) {
            //if(!tokenEnabledState(_hashId, _numToken)) ***tokenEnabledState currently deprecated
            //revert WavDBC__BitValIssue();
            // resolve tier and compute price from state map
            // ***** Needs to be able to return <x> page based on numToken
            //uint256 _priceMap = ReturnContentToken.returnSPriceMap(_hashId, 0);
            uint16 _pages = uint16((uint256(_wavSaleToken.numToken) + 63) >> 6);

            uint256 _priceMap = ReturnMapMapping.returnSPriceMap(
                _wavSaleToken.hashId,
                _pages
            );
            uint8 _priceState = Binary2BitDBC._decode2BitState(
                _priceMap,
                _wavSaleToken.numToken
            );
            uint256 _usdPrice = PriceDBC._sPriceUsdValState(
                _priceState,
                _sPriceUsdVal
            );

            ContentTokenSupplyMapStorage.ContentTokenSupplyMap
                storage ContentTokenSupplyMapStruct = ContentTokenSupplyMapStorage
                    .contentTokenSupplyMapStorage();

            // debit tier pre-release supply
            {
                uint16 _wordIndex = _wavSaleToken.numToken >> 6;
                uint8 _within = uint8(_wavSaleToken.numToken & 63);

                uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                    _wavSaleToken.hashId
                ][_wordIndex];
                uint256 _shift = uint256(_within) * 4;
                uint8 _tierId = uint8((_packed >> _shift) & 0xF);
                /*LibWavSupplies.sDebitWavStoreSupply(
                    _wavSaleToken.hashId,
                    _tierId,
                    _wavSaleToken.purchaseQuantity
                );*/

                LibWavSupplies.sDebitWavStoreSupply2(_wavSaleToken, _tierId);
            }

            return LibFeed._usdToWei(_usdPrice);
        }

        revert ValidateWavSale__InputError404();
    }
}
