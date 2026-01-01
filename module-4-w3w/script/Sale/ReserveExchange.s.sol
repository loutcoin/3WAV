// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    ReserveExchange
} from "../../src/3WAVi__ORIGINS/Sale/ReserveExchange.sol";

contract ReserveExchangeScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        ReserveExchange reserveExchange = new ReserveExchange();
        _facetAddress = address(reserveExchange);

        vm.stopBroadcast();
    }
}
