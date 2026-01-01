// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavSaleBatch} from "../../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

contract WavSaleBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavSaleBatch wavSaleBatch = new WavSaleBatch();
        _facetAddress = address(wavSaleBatch);

        vm.stopBroadcast();
    }
}
