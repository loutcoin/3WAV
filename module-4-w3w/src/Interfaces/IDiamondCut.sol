// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {LibDiamond} from "../Diamond__Libraries/LibDiamond.sol";

interface IDiamondCut {
    function diamondCut(
        LibDiamond.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external;

    event DiamondCut(
        LibDiamond.FacetCut[] _diamondCut,
        address _init,
        bytes _calldata
    );
}
