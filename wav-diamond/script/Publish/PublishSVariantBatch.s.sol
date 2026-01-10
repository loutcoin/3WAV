// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishSVariantBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishSVariantBatch.sol";

contract PublishSVariantBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishSVariantBatch publishSVariantBatch = new PublishSVariantBatch();
        _facetAddress = address(publishSVariantBatch);

        vm.stopBroadcast();
    }
}
