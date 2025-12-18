// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {
    FacetAddrStorage
} from "../../src/Diamond__Storage/ActiveAddresses/FacetAddrStorage.sol";
import {ReturnValidation} from "../../src/3WAVi__Helpers/ReturnValidation.sol";

import {LibFeed} from "../../src/3WAVi__Helpers/FacetHelpers/LibFeed.sol";

contract WavZip {
    /**
     * @notice Updates the official recognized address of WavAccess.
     * @dev Accesses FacetAddrStruct to update the value of s_wavAccess.
     *      Function Selector: 0xa64eb27e
     * @param _updatedAddr Input of updated facet address.
     */
    function assignWavAcccess(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavAccess = _updatedAddr;
    }

    /*
     * @notice Updates the official recognized address of WavDBC.
     * @dev Accesses FacetAddrStruct to update the value of s_wavDBC.
     *      Function Selector: 0x9028d4f0
     * @param _updatedAddr Input of updated facet address.
     */
    /*function assignWavDBC(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavDBC = _updatedAddr;
    }*/

    /*
     * @notice Updates the official recognized address of WavFeed.
     * @dev Accesses FacetAddrStruct to update the value of s_wavFeed.
     *      Function Selector: 0xb5851176
     * @param _updatedAddr Input of updated facet address.
     */
    /*function assignWavFeed(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavFeed = _updatedAddr;
    }*/

    /*
     * @notice Updates the official recognized address of WavStore.
     * @dev Accesses FacetAddrStruct to update the value of s_wavStore.
     *      Function Selector: 0x2a9c5420
     * @param _updatedAddr Input of updated facet address.
     */
    /*function assignWavStore(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavStore = _updatedAddr;
    }*/

    /*
     * @notice Updates the official recognized address of WavToken.
     * @dev Accesses FacetAddrStruct to update the value of s_wavToken.
     *      Function Selector: 0xd5980e7c
     * @param _updatedAddr Input of updated facet address.
     */
    /*function assignWavToken(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavToken = _updatedAddr;
    }*/

    /*
     * @notice Updates the official recognized address of WavZip.
     * @dev Accesses FacetAddrStruct to update the value of s_wavZip.
     *      Function Selector: 0xc0428ba1
     * @param _updatedAddr Input of updated facet address.
     */
    /*function assignWavZip(address _updatedAddr) external {
        ReturnValidation.returnIsAuthorized();
        FacetAddrStorage.FacetAddrStruct
            storage FacetAddrStructStorage = FacetAddrStorage
                .facetAddrStorage();
        FacetAddrStructStorage.s_wavZip = _updatedAddr;
    }*/

    function setPriceFeed(address _priceFeed) external {
        // Access control
        LibFeed._setPriceFeed(_priceFeed);
    }

    function returnPriceFeedAddress() external view returns (address) {
        return LibFeed._returnPriceFeedAddress();
    }
}
