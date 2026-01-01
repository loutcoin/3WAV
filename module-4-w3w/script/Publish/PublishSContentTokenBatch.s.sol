// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishSContentTokenBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";

contract PublishSContentTokenBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishSContentTokenBatch publishSContentTokenBatch = new PublishSContentTokenBatch();
        _facetAddress = address(publishSContentTokenBatch);

        vm.stopBroadcast();
    }
}
