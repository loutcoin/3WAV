// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {LibDiamond} from "../../src/Diamond__Libraries/LibDiamond.sol";

import {IDiamondCut} from "../../src/Interfaces/IDiamondCut.sol";

import {LibUtil} from "../../src/Diamond__Libraries/LibUtil.sol";

contract WavDiamond {
    constructor(address _contractOwner, address _diamondCutFacet) payable {
        LibDiamond.setContractOwner(_contractOwner);

        // Add the external diamondCut function from the diamondCutFacet
        LibDiamond.FacetCut[] memory cut = new LibDiamond.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = LibDiamond.FacetCut({
            facetAddress: _diamondCutFacet,
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");
    }

    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_SLOT;

        // get diamond storage
        // solhint-disable-next-line no-inline-assembly
        assembly {
            ds.slot := position
        }

        // get facet from function selector
        address facet = ds.selectorToFacetAndPosition[msg.sig].facetAddress;
        if (facet == address(0)) {
            revert LibDiamond.system__FunctionDoesNotExist();
        }
        // Execute external function from facet using delegatecall and return any value.
        // solhint-disable-next-line no-inline-assembly

        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the facet
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    // able to receive ETH
    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
