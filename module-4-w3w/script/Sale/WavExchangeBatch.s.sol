// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    WavExchangeBatch
} from "../../src/3WAVi__ORIGINS/Sale/WavExchangeBatch.sol";

contract WavExchangeBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavExchangeBatch wavExchangeBatch = new WavExchangeBatch();
        _facetAddress = address(wavExchangeBatch);

        vm.stopBroadcast();
    }
}
