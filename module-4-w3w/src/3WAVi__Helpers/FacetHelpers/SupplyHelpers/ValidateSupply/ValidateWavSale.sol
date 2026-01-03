// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    ContentTokenSupplyMapStorage
} from "../../../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    LibFeed
} from "../../../../../src/3WAVi__Helpers/FacetHelpers/LibFeed.sol";

import {
    LibWavSupplies
} from "../../../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/DebitSupply/LibWavSupplies.sol";

import {
    Binary2BitDBC
} from "../../../../../src/3WAVi__Helpers/DBC/Binary2BitDBC.sol";

import {PriceDBC} from "../../../../../src/3WAVi__Helpers/DBC/PriceDBC.sol";

import {
    ReturnContentToken
} from "../../../../../src/3WAVi__Helpers/ReturnMapping/ReturnContentToken.sol";

import {
    ReturnMapMapping
} from "../../../../../src/3WAVi__Helpers/ReturnMapping/ReturnMapMapping.sol";

import {
    WavSaleToken
} from "../../../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

library ValidateWavSale {
    error ValidateWavSale__InputError404();

    /**
     * @notice Validates price property, converts to wei, and debits supply.
     * @dev Authenticates Content Token WavStore supply and pricing data prior to sale.
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
            // Resolve tier and compute price from state map
            // Pages based on zero index
            uint16 _pages = uint16(((_wavSaleToken.numToken - 1) >> 6));

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

            {
                // debit tier pre-release supply
                uint16 _wordIndex = _wavSaleToken.numToken >> 6;
                uint8 _within = uint8(_wavSaleToken.numToken & 63);
                uint256 _packed = ContentTokenSupplyMapStruct.s_tierMap[
                    _wavSaleToken.hashId
                ][_wordIndex];

                uint256 _shift = uint256(_within) * 4;
                uint8 _tierId = uint8((_packed >> _shift) & 0xF);

                _tierId++;

                LibWavSupplies.sDebitWavStoreSupplySale(_wavSaleToken, _tierId);
            }

            return LibFeed._usdToWei(_usdPrice);
        }

        revert ValidateWavSale__InputError404();
    }
}
