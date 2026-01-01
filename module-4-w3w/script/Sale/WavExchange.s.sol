// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavExchange} from "../../src/3WAVi__ORIGINS/Sale/WavExchange.sol";

contract WavExchangeScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavExchange wavExchange = new WavExchange();
        _facetAddress = address(wavExchange);

        vm.stopBroadcast();
    }
}
