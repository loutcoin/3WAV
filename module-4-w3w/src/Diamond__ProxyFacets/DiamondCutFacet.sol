// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDiamondCut} from "../Interfaces/IDiamondCut.sol";
import {LibDiamond} from "../Diamond__Libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    // function selector: 0x1f931c1c
    function diamondCut(
        LibDiamond.FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external {
        LibDiamond.enforceContractOwner();
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
// cast sig "diamondCut((address,uint8,bytes4[])[],address,bytes)"
