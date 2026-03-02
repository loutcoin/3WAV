// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibAllocateWavSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/AllocateSupply/LibAllocateWavSuppliesBatch.sol";

// consolidate into LibAllocateWavSupplies by moving shift logic for maximum slot access efficiency
import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract AllocateWavStoreBatch {
    event AllocatedToWavStoreBatch(uint256 indexed _totalAllocations);

    function allocateUnallocatedToWavStoreBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized;

        {
            LibAllocateWavSuppliesBatch._allocateUnallocatedToWavStoreBatch(
                _wavSaleToken
            );
        }

        emit AllocatedToWavStoreBatch(_wavSaleToken.length);
    }
}
