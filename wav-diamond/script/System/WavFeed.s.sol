// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavFeed} from "../../src/3WAVi__ORIGINS/WavFeed.sol";

contract WavFeedScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavFeed wavFeed = new WavFeed();
        _facetAddress = address(wavFeed);

        vm.stopBroadcast();
    }
}
