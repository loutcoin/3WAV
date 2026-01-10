// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishCVariantBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishCVariantBatch.sol";

contract PublishCVariantBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishCVariantBatch publishCVariantBatch = new PublishCVariantBatch();
        _facetAddress = address(publishCVariantBatch);

        vm.stopBroadcast();
    }
}
