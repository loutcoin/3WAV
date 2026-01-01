// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishCContentTokenBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";

contract PublishCContentTokenBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishCContentTokenBatch publishCContentTokenBatch = new PublishCContentTokenBatch();
        _facetAddress = address(publishCContentTokenBatch);

        vm.stopBroadcast();
    }
}
