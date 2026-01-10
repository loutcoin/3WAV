// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {
    ReserveExchangeBatch
} from "../../src/3WAVi__ORIGINS/Sale/ReserveExchangeBatch.sol";

contract ReserveExchangeBatchScript is Script {
    function run() external returns (address _facetAddress) {
        vm.startBroadcast();

        ReserveExchangeBatch reserveExchangeBatch = new ReserveExchangeBatch();
        _facetAddress = address(reserveExchangeBatch);

        vm.stopBroadcast();
    }
}
