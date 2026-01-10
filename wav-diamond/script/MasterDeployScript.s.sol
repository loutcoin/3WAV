// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Forge-std
import {Script} from "../lib/forge-std/src/Script.sol";

// Diamond-Specific
import {WavDiamond} from "../src/3WAVi__ORIGINS/WavDiamond.sol";
import {DiamondCutFacet} from "../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";

import {IDiamondCut} from "../src/Interfaces/IDiamondCut.sol";
import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../src/Diamond__Libraries/LibDiamond.sol";
import {LibDiamondLoupe} from "../src/Diamond__Libraries/LibDiamondLoupe.sol";

// Publish Facets
import {
    PublishCContentToken
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";
import {
    PublishCContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";
import {
    PublishCVariant
} from "../src/3WAVi__ORIGINS/Publish/PublishCVariant.sol";
import {
    PublishCVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCVariantBatch.sol";
import {
    PublishSContentToken
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";
import {
    PublishSContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";
import {
    PublishSVariant
} from "../src/3WAVi__ORIGINS/Publish/PublishSVariant.sol";
import {
    PublishSVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSVariantBatch.sol";

// Sale Facets
import {PreReleaseSale} from "../src/3WAVi__ORIGINS/Sale/PreReleaseSale.sol";
import {
    PreReleaseSaleBatch
} from "../src/3WAVi__ORIGINS/Sale/PreReleaseSaleBatch.sol";
import {ProfitWithdrawl} from "../src/3WAVi__ORIGINS/Sale/ProfitWithdrawl.sol";
import {ReserveExchange} from "../src/3WAVi__ORIGINS/Sale/ReserveExchange.sol";
import {
    ReserveExchangeBatch
} from "../src/3WAVi__ORIGINS/Sale/ReserveExchangeBatch.sol";
import {WavExchange} from "../src/3WAVi__ORIGINS/Sale/WavExchange.sol";
import {
    WavExchangeBatch
} from "../src/3WAVi__ORIGINS/Sale/WavExchangeBatch.sol";
import {WavSale} from "../src/3WAVi__ORIGINS/Sale/WavSale.sol";
import {WavSaleBatch} from "../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

// System Facets
import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";
import {WavFeed} from "../src/3WAVi__ORIGINS/WavFeed.sol";
import {WavFortress} from "../src/3WAVi__ORIGINS/WavFortress.sol";

contract MasterDeployScript is Script {
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishCVariant public publishCVariant;
    PublishCVariantBatch public publishCVariantBatch;
    PublishSContentToken public publishSContentToken;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    PublishSVariant public publishSVariant;
    PublishSVariantBatch public publishSVariantBatch;
    PreReleaseSale public preReleaseSale;
    PreReleaseSaleBatch public preReleaseSaleBatch;
    ProfitWithdrawl public profitWithdrawl;
    ReserveExchange public reserveExchange;
    ReserveExchangeBatch public reserveExchangeBatch;
    WavExchange public wavExchange;
    WavExchangeBatch public wavExchangeBatch;
    WavSale public wavSale;
    WavSaleBatch public wavSaleBatch;
    WavAccess public wavAccess;
    WavFeed public wavFeed;
    WavFortress public wavFortress;

    function run() external {
        vm.startBroadcast();

        address _owner = msg.sender;

        address feed = vm.envAddress("PRICE_FEED");
        if (feed == address(0)) {
            if (block.chainid == 11155111) {
                feed = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
            }
        }

        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        WavDiamond wavDiamond = new WavDiamond(
            _owner,
            address(diamondCutFacet)
        );
        diamondLoupeFacet = new DiamondLoupeFacet();

        uint256 _index = 0;

        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](21);

        // Diamond

        bytes4[] memory _loupeSelectors = new bytes4[](3);
        _loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        _loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        _loupeSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        _cut[_index] = LibDiamond.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _loupeSelectors
        });
        _index++;

        {
            publishCContentToken = new PublishCContentToken();
            publishCContentTokenBatch = new PublishCContentTokenBatch();
            publishCVariant = new PublishCVariant();
            publishCVariantBatch = new PublishCVariantBatch();
            publishSContentToken = new PublishSContentToken();
            publishSContentTokenBatch = new PublishSContentTokenBatch();
            publishSVariant = new PublishSVariant();
            publishSVariantBatch = new PublishSVariantBatch();

            // Publish (CContentToken)

            bytes4[] memory _publishCCTSelectors = new bytes4[](1);
            _publishCCTSelectors[0] = PublishCContentToken
                .publishCContentToken
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishCContentToken),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishCCTSelectors
            });
            _index++;

            bytes4[] memory _publishCCTBSelectors = new bytes4[](1);
            _publishCCTBSelectors[0] = PublishCContentTokenBatch
                .publishCContentTokenBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishCContentTokenBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishCCTBSelectors
            });
            _index++;

            bytes4[] memory _publishCVSelectors = new bytes4[](1);
            _publishCVSelectors[0] = PublishCVariant.publishCVariant.selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishCVariant),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishCVSelectors
            });
            _index++;

            bytes4[] memory _publishCVBSelectors = new bytes4[](2);
            _publishCVBSelectors[0] = PublishCVariantBatch
                .publishCVariantBatch
                .selector;
            _publishCVBSelectors[1] = PublishCVariantBatch
                .publishCContentTokenVariantBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishCVariantBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishCVBSelectors
            });
            _index++;

            // Publish (SContentToken)

            bytes4[] memory _publishSCTSelectors = new bytes4[](1);
            _publishSCTSelectors[0] = PublishSContentToken
                .publishSContentToken
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishSContentToken),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishSCTSelectors
            });
            _index++;

            bytes4[] memory _publishSCTBSelectors = new bytes4[](1);
            _publishSCTBSelectors[0] = PublishSContentTokenBatch
                .publishSContentTokenBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishSContentTokenBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishSCTBSelectors
            });
            _index++;

            bytes4[] memory _publishSVSelectors = new bytes4[](1);
            _publishSVSelectors[0] = PublishSVariant.publishSVariant.selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishSVariant),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishSVSelectors
            });
            _index++;

            bytes4[] memory _publishSVBSelectors = new bytes4[](2);
            _publishSVBSelectors[0] = PublishSVariantBatch
                .publishSVariantBatch
                .selector;
            _publishSVBSelectors[1] = PublishSVariantBatch
                .publishSContentTokenVariantBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(publishSVariantBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _publishSVBSelectors
            });
            _index++;
        }

        {
            preReleaseSale = new PreReleaseSale();
            preReleaseSaleBatch = new PreReleaseSaleBatch();
            profitWithdrawl = new ProfitWithdrawl();
            reserveExchange = new ReserveExchange();
            reserveExchangeBatch = new ReserveExchangeBatch();
            wavExchange = new WavExchange();
            wavExchangeBatch = new WavExchangeBatch();
            wavSale = new WavSale();
            wavSaleBatch = new WavSaleBatch();

            // Sale:

            bytes4[] memory _preReleaseSaleSelectors = new bytes4[](1);
            _preReleaseSaleSelectors[0] = PreReleaseSale
                .preReleasePurchaseSingle
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(preReleaseSale),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _preReleaseSaleSelectors
            });
            _index++;

            bytes4[] memory _preReleaseSaleBatchSelectors = new bytes4[](1);
            _preReleaseSaleBatchSelectors[0] = PreReleaseSaleBatch
                .preReleasePurchaseBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(preReleaseSaleBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _preReleaseSaleBatchSelectors
            });
            _index++;

            bytes4[] memory _profitWithdrawlSelectors = new bytes4[](3);
            _profitWithdrawlSelectors[0] = ProfitWithdrawl
                .withdrawEthEarnings
                .selector;
            _profitWithdrawlSelectors[1] = ProfitWithdrawl
                .returnEthEarnings
                .selector;
            _profitWithdrawlSelectors[2] = ProfitWithdrawl
                .getCollaboratorReserve
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(profitWithdrawl),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _profitWithdrawlSelectors
            });
            _index++;

            bytes4[] memory _reserveExchangeSelectors = new bytes4[](1);
            _reserveExchangeSelectors[0] = ReserveExchange
                .reserveExchangeSingle
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(reserveExchange),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _reserveExchangeSelectors
            });
            _index++;

            bytes4[] memory _reserveExchangeBatchSelectors = new bytes4[](1);
            _reserveExchangeBatchSelectors[0] = ReserveExchangeBatch
                .reserveExchangeBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(reserveExchangeBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _reserveExchangeBatchSelectors
            });
            _index++;

            bytes4[] memory _wavExchangeSelectors = new bytes4[](2);
            _wavExchangeSelectors[0] = WavExchange.wavResaleSingle.selector;
            _wavExchangeSelectors[1] = WavExchange.wavExchange.selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(wavExchange),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _wavExchangeSelectors
            });
            _index++;

            bytes4[] memory _wavExchangeBatchSelectors = new bytes4[](2);
            _wavExchangeBatchSelectors[0] = WavExchangeBatch
                .wavResaleBatch
                .selector;
            _wavExchangeBatchSelectors[1] = WavExchangeBatch
                .wavExchangeBatch
                .selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(wavExchangeBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _wavExchangeBatchSelectors
            });
            _index++;

            bytes4[] memory _wavSaleSelectors = new bytes4[](2);
            _wavSaleSelectors[0] = WavSale.wavSaleSingle.selector;
            _wavSaleSelectors[1] = WavSale.wavAccess.selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(wavSale),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _wavSaleSelectors
            });
            _index++;

            bytes4[] memory _wavSaleBatchSelectors = new bytes4[](2);
            _wavSaleBatchSelectors[0] = WavSaleBatch.wavSaleBatch.selector;
            _wavSaleBatchSelectors[1] = WavSaleBatch.wavAccessBatch.selector;

            _cut[_index] = LibDiamond.FacetCut({
                facetAddress: address(wavSaleBatch),
                action: LibDiamond.FacetCutAction.Add,
                functionSelectors: _wavSaleBatchSelectors
            });
            _index++;
        }

        wavAccess = new WavAccess();
        wavFeed = new WavFeed();
        wavFortress = new WavFortress();

        // System
        bytes4[] memory _wavAccessSelectors = new bytes4[](6);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;
        _wavAccessSelectors[5] = WavAccess.returnHourStamp.selector;

        _cut[_index] = LibDiamond.FacetCut({
            facetAddress: address(wavAccess),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavAccessSelectors
        });
        _index++;

        bytes4[] memory _wavFeedSelectors = new bytes4[](5);
        _wavFeedSelectors[0] = WavFeed.setPriceFeed.selector;
        _wavFeedSelectors[1] = WavFeed.returnPriceFeedAddress.selector;
        _wavFeedSelectors[2] = WavFeed.getLatestPrice.selector;
        _wavFeedSelectors[3] = WavFeed.usdToWei.selector;
        _wavFeedSelectors[4] = WavFeed.usdToEthBatch.selector;

        _cut[_index] = LibDiamond.FacetCut({
            facetAddress: address(wavFeed),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavFeedSelectors
        });
        _index++;

        bytes4[] memory _wavFortressSelectors = new bytes4[](1);
        _wavFortressSelectors[0] = WavFortress.getCurrentNonce.selector;

        _cut[_index] = LibDiamond.FacetCut({
            facetAddress: address(wavFortress),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavFortressSelectors
        });
        _index++;

        require(_index == _cut.length, "Facet cut mismatch");
        IDiamondCut(address(wavDiamond)).diamondCut(_cut, address(0), "");

        WavAccess(address(wavDiamond)).addOwnerAddr(_owner);

        require(feed != address(0), "PRICE_FEED not set");
        WavFeed(address(wavDiamond)).setPriceFeed(feed);

        vm.stopBroadcast();
    }
}
