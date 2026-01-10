// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {WavFortress} from "../../src/3WAVi__ORIGINS/WavFortress.sol";

contract WavFortressScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        WavFortress wavFortress = new WavFortress();
        _facetAddress = address(wavFortress);

        vm.stopBroadcast();
    }
}
