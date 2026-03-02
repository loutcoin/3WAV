// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {
    ReturnValidation
} from "../../../src/3WAVi__Helpers/ReturnValidation.sol";

import {
    LibAllocateWavReserveSuppliesBatch
} from "../../../src/3WAVi__Helpers/FacetHelpers/SupplyHelpers/AllocateSupply/LibAllocateWavReserveSuppliesBatch.sol";

// consolidate into LibAllocateWavSupplies by moving shift logic for maximum slot access efficiency
import {
    ContentTokenSupplyMapStorage
} from "../../../src/Diamond__Storage/ContentToken/ContentTokenSupplyMapStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

contract AllocateWavReserveBatch {
    event AllocatedToWavReserveBatch(uint256 indexed _totalAllocations);

    function allocateUnallocatedToWavReserveBatch(
        WavSaleToken.WavSale[] calldata _wavSaleToken
    ) external {
        ReturnValidation.returnIsAuthorized;

        {
            LibAllocateWavReserveSuppliesBatch
                ._allocateUnallocatedToWavReserveBatch(_wavSaleToken);
        }

        emit AllocatedToWavReserveBatch(_wavSaleToken.length);
    }
}
