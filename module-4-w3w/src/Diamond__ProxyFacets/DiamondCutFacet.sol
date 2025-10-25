// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IDiamondCut} from "../Interfaces/IDiamondCut.sol";
import {LibDiamond} from "../Diamond__Libraries/LibDiamond.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(
        LibDiamond.FacetCut[] calldata _diamondCut,
        address _init,
        byters calldata _calldata
    ) external {
        LibDiamond.enforceContractOwner();
        LibDiamond.diamondCut(_diamondCut, _init, _calldata);
    }
}
