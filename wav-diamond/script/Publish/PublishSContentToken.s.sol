// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    PublishSContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";

contract PublishSContentTokenScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        PublishSContentToken publishSContentToken = new PublishSContentToken();
        _facetAddress = address(publishSContentToken);

        vm.stopBroadcast();
    }
}
