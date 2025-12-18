// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../src/3WAVi__ORIGINS/WavDiamond.sol";
import {DiamondCutFacet} from "../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../src/Diamond__Libraries/LibDiamond.sol";

//import {StdCheats} from "../lib/forge-std/src/StdCheats.sol";

import {
    PublishCContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";

import {
    PublishSContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";

import {
    PublishSVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSVariantBatch.sol";

import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";

import {WavSaleBatch} from "../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

import {
    PreReleaseSaleBatch
} from "../src/3WAVi__ORIGINS/Sale/PreReleaseSaleBatch.sol";

import {
    PreReleaseStateBatch
} from "../src/3WAVi__ORIGINS/Sale/State/PreReleaseStateBatch.sol";

import {
    PostEndReleaseBatch
} from "../src/3WAVi__ORIGINS/Sale/State/PostEndReleaseBatch.sol";

import {
    CreatorTokenStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CContentTokenStorage
} from "../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    WavSaleToken
} from "../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {
    CollaboratorStructStorage
} from "../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../src/Interfaces/IDiamondCut.sol";

contract SaleStateAssertionBatch is Test {
    uint112 constant EX_CSUPPLY_01 = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_CSUPPLY_PR = 100000099990000000999100000100000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 10%
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,
    uint96 constant EX_RELEASE_STAMP_PR = 4900560000004900500; // 490050
    uint96 constant EX_CRELEASE_END_01 = 4900564900600000000;

    // 490140 * 3600 = 1764504000
    // 490150 * 3600 = 1764540000

    uint96 constant EX_PURCHASE_STAMP = 1764208800; // '490058' hourStamp
    uint96 constant EX_ELAPSED_PURCHASE_STAMP = 1764219600; // '490061' hourStamp
    uint96 constant EX_PR_PURCHASE_STAMP = 1764183600; // '490051' hourStamp
    uint96 constant EX_PR_EARLY_PURCHASE_STAMP = 1764176400; // '490049' hourStamp
    uint96 constant EX_POST_END_PURCHASE_STAMP = 1764540000; // '490150' hourStamp

    uint8 constant EX_PR_PAUSED = 1;

    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    PublishSVariantBatch public publishSVariantBatch;
    WavSaleBatch public wavSaleBatch;
    WavAccess public wavAccess;
    PreReleaseSaleBatch public preReleaseSaleBatch;
    PreReleaseStateBatch public preReleaseStateBatch;
    PostEndReleaseBatch public postEndReleaseBatch;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
    uint256 public ownerKey =
        0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;

    address public buyer_01 =
        address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);
    address public buyer_02 =
        address(0x14dC79964da2C08b23698B3D3cc7Ca32193d9955);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentTokenBatch = new PublishCContentTokenBatch();
        publishSContentTokenBatch = new PublishSContentTokenBatch();
        publishSVariantBatch = new PublishSVariantBatch();
        wavAccess = new WavAccess();
        wavSaleBatch = new WavSaleBatch();
        preReleaseSaleBatch = new PreReleaseSaleBatch();
        preReleaseStateBatch = new PreReleaseStateBatch();
        postEndReleaseBatch = new PostEndReleaseBatch();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        //wavAccess = new WavAccess();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        // Build the cut array (which facet selectors to include)
        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](10);

        // Publish facet selectors
        bytes4[] memory _publishCCTBSelectors = new bytes4[](1);
        _publishCCTBSelectors[0] = PublishCContentTokenBatch
            .publishCContentTokenBatch
            .selector;

        _cut[0] = LibDiamond.FacetCut({
            facetAddress: address(publishCContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCCTBSelectors
        });

        bytes4[] memory _publishSVBSelectors = new bytes4[](2);
        _publishSVBSelectors[0] = PublishSVariantBatch
            .publishSVariantBatch
            .selector;

        bytes4[] memory _publishSCTBSelectors = new bytes4[](1);
        _publishSCTBSelectors[0] = PublishSContentTokenBatch
            .publishSContentTokenBatch
            .selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTBSelectors
        });

        _publishSVBSelectors[1] = PublishSVariantBatch
            .publishSContentTokenVariantBatch
            .selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariantBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVBSelectors
        });

        bytes4[] memory _loupeSelectors = new bytes4[](3);
        _loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        _loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        _loupeSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _loupeSelectors
        });

        bytes4[] memory _setterSelectors = new bytes4[](1);
        _setterSelectors[0] = TestPriceFeedSetter.setPriceFeed.selector;

        _cut[4] = LibDiamond.FacetCut({
            facetAddress: address(priceSetterFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _setterSelectors
        });

        bytes4[] memory _wavSaleBatchSelectors = new bytes4[](2);
        _wavSaleBatchSelectors[0] = WavSaleBatch.wavSaleBatch.selector;
        _wavSaleBatchSelectors[1] = WavSaleBatch.wavAccessBatch.selector;

        _cut[5] = LibDiamond.FacetCut({
            facetAddress: address(wavSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleBatchSelectors
        });

        bytes4[] memory _preReleaseSaleBatchSelectors = new bytes4[](1);
        _preReleaseSaleBatchSelectors[0] = PreReleaseSaleBatch
            .preReleasePurchaseBatch
            .selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(preReleaseSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _preReleaseSaleBatchSelectors
        });

        bytes4[] memory _preReleaseStateBatchSelectors = new bytes4[](1);
        _preReleaseStateBatchSelectors[0] = PreReleaseStateBatch
            .preReleaseStateBatch
            .selector;

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(preReleaseStateBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _preReleaseStateBatchSelectors
        });

        bytes4[] memory _postEndReleaseBatchSelectors = new bytes4[](1);
        _postEndReleaseBatchSelectors[0] = PostEndReleaseBatch
            .postManualEndReleaseBatch
            .selector;

        _cut[8] = LibDiamond.FacetCut({
            facetAddress: address(postEndReleaseBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _postEndReleaseBatchSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](8);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnership2.selector;
        _wavAccessSelectors[2] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[3] = WavAccess.returnOwnershipIndex2.selector;
        _wavAccessSelectors[4] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[5] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[6] = WavAccess.removeApprovedAddr.selector;
        _wavAccessSelectors[7] = WavAccess.returnHourStamp.selector;

        _cut[9] = LibDiamond.FacetCut({
            facetAddress: address(wavAccess),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavAccessSelectors
        });

        vm.prank(owner);
        IDiamondCut(address(wavDiamond)).diamondCut(_cut, address(0), "");

        vm.prank(owner);
        TestPriceFeedSetter(address(wavDiamond)).setPriceFeed(
            address(_mockAggregator)
        );

        vm.prank(owner);
        WavAccess(address(wavDiamond)).addOwnerAddr(owner);
    }

    // forge test --match-test testWavSaleCContentTokenEndReleaseBatchAssertion -vvvv

    function testWavSaleCContentTokenEndReleaseBatchAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_01,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_CRELEASE_END_01
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_01,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_CRELEASE_END_01
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_ELAPSED_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testWavSaleSVariantEndReleaseBatchAssertion -vvvv

    function testWavSaleSVariantEndReleaseBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_END_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_END_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );
        }

        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(2),
                    hashId: bytes32(
                        0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_01),
            releaseVal: uint96(EX_CRELEASE_END_01)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(3),
                    hashId: bytes32(
                        0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                    )
                }),
                baseHashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_01),
            releaseVal: uint96(EX_CRELEASE_END_01)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(owner);
        PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[0].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[1].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_ELAPSED_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testWavSaleCContentTokenPreReleaseActiveBatchAssertion -vvvv

    function testWavSaleCContentTokenPreReleaseActiveBatchAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testWavSaleSVariantPreReleaseActiveBatchAssertion -vvvv

    function testWavSaleSVariantPreReleaseActiveBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // was both '1' just temporarily modified
            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            // cContentToken[1]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCContentTokenBatch(address(wavDiamond))
                .publishCContentTokenBatch(
                    _creatorToken,
                    _cContentToken,
                    _collaborator,
                    _tierPages,
                    _pricePages
                );
        }

        {
            CreatorTokenVariantStorage.CreatorTokenVariant[]
                memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            _creatorTokenVariant[0] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(2),
                        hashId: bytes32(
                            0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                        )
                    }),
                    baseHashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_END_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _creatorTokenVariant[1] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(3),
                        hashId: bytes32(
                            0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                        )
                    }),
                    baseHashId: bytes32(
                        0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_END_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
                _creatorTokenVariant,
                _sContentToken,
                _collaborator
            );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);

            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[0].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[1].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 _totalWei = 0;

            {
                uint256 feedAnswer = uint256(3000 * 10 ** 8);
                uint256 usdVal = 349; // 3.49$
                uint256 usd8 = usdVal * 1e6;
                uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiZero;

                usdVal = 349;
                usd8 = usdVal * 1e6;
                uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiOne;

                vm.expectRevert();
                vm.deal(buyer_01, 5 ether);
                vm.prank(owner);
                vm.warp(EX_PR_PURCHASE_STAMP);
                WavSaleBatch(address(wavDiamond)).wavSaleBatch{
                    value: _totalWei
                }(buyer_01, _wavSaleToken);
            }
        }
    }

    // forge test --match-test testPreReleaseCContentTokenStartReleaseBatchAssertion -vvvv

    function testPreReleaseCContentTokenStartReleaseBatchAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_ELAPSED_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer_01, _wavSaleToken);
        }
    }

    // forge test --match-test testPreReleaseSVariantStartReleaseBatchAssertion -vvvv

    function testPreReleaseSVariantStartReleaseBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // was both '1' just temporarily modified
            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            // cContentToken[1]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCContentTokenBatch(address(wavDiamond))
                .publishCContentTokenBatch(
                    _creatorToken,
                    _cContentToken,
                    _collaborator,
                    _tierPages,
                    _pricePages
                );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant[]
                memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            _creatorTokenVariant[0] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(2),
                        hashId: bytes32(
                            0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                        )
                    }),
                    baseHashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _creatorTokenVariant[1] = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(3),
                        hashId: bytes32(
                            0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                        )
                    }),
                    baseHashId: bytes32(
                        0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                    ),
                    variantIndex: uint16(1)
                });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
                _creatorTokenVariant,
                _sContentToken,
                _collaborator
            );

            WavSaleToken.WavSale[]
                memory _wavSaleToken = new WavSaleToken.WavSale[](2);

            _wavSaleToken[0] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[0].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            _wavSaleToken[1] = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant[1].creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 _totalWei = 0;

            {
                uint256 feedAnswer = uint256(3000 * 10 ** 8);
                uint256 usdVal = 349; // 3.49$
                uint256 usd8 = usdVal * 1e6;
                uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiZero;

                usdVal = 349;
                usd8 = usdVal * 1e6;
                uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
                _totalWei += _weiOne;

                vm.expectRevert();
                vm.deal(buyer_01, 5 ether);
                vm.prank(owner);
                vm.warp(EX_ELAPSED_PURCHASE_STAMP);
                PreReleaseSaleBatch(address(wavDiamond))
                    .preReleasePurchaseBatch{value: _totalWei}(
                    buyer_01,
                    _wavSaleToken
                );
            }
        }
    }

    // forge test --match-test testPreReleaseCContentTokenEarlySaleAssertion -vvvv

    function testPreReleaseCContentTokenEarlySaleAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_EARLY_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer_01, _wavSaleToken);
        }
    }

    // forge test --match-test testPreReleaseSVariantEarlySaleBatchAssertion -vvvv

    function testPreReleaseSVariantEarlySaleBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            CContentTokenStorage.CContentToken[]
                memory _cContentToken = new CContentTokenStorage.CContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // was both '1' just temporarily modified
            uint256[] memory _tierPages = new uint256[](2);
            uint256[] memory _pricePages = new uint256[](2);

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _cContentToken[0] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            _tierPages[0] = uint256(0x058885580);
            _pricePages[0] = uint256(0x5564);

            // cContentToken[1]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _cContentToken[1] = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_RELEASE_STAMP_PR
            });

            _collaborator[1] = _collaborator[0];

            _tierPages[1] = uint256(0x058885580);
            _pricePages[1] = uint256(0x5564);

            vm.prank(owner);
            PublishCContentTokenBatch(address(wavDiamond))
                .publishCContentTokenBatch(
                    _creatorToken,
                    _cContentToken,
                    _collaborator,
                    _tierPages,
                    _pricePages
                );
        }

        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(2),
                    hashId: bytes32(
                        0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(3),
                    hashId: bytes32(
                        0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                    )
                }),
                baseHashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(owner);
        PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[0].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[1].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_EARLY_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer_01, _wavSaleToken);
        }
    }

    // forge test --match-test testPreReleaseCContentTokenPausedAtAssertion -vvvv

    function testPreReleaseCContentTokenPausedAtBatchAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        uint8[] memory _pausedAtStates = new uint8[](2);
        _pausedAtStates[0] = uint8(1);
        _pausedAtStates[1] = uint8(1);

        bytes32[] memory _hashIdBatch = new bytes32[](2);
        _hashIdBatch[0] = _creatorToken[0].hashId;
        _hashIdBatch[1] = _creatorToken[1].hashId;

        vm.prank(owner);

        PreReleaseStateBatch(address(wavDiamond)).preReleaseStateBatch(
            _hashIdBatch,
            _pausedAtStates
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer_01, _wavSaleToken);
        }
    }

    // forge test --match-test testPreReleaseSVariantPausedAtBatchAssertion -vvvv

    /*function testPreReleaseSVariantPausedAtBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(publisher);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );
        }

        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(2),
                    hashId: bytes32(
                        0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(3),
                    hashId: bytes32(
                        0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                    )
                }),
                baseHashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(publisher);
        PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        uint8[] memory _pausedAtStates = new uint8[](2);
        _pausedAtStates[0] = uint8(1);
        _pausedAtStates[1] = uint8(1);

        bytes32[] memory _hashIdBatch = new bytes32[](2);
        _hashIdBatch[0] = _creatorTokenVariant[0].creatorToken.hashId;
        _hashIdBatch[1] = _creatorTokenVariant[1].creatorToken.hashId;

        PreReleaseStateBatch(address(wavDiamond)).preReleaseStateBatch(
            _hashIdBatch,
            _pausedAtStates
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[0].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[1].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;
        }

        {
            uint256 usdVal = EX_CPRICE_USD_01;
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;
        }

        vm.expectRevert();
        vm.deal(buyer_01, 5 ether);
        vm.prank(buyer_01);
        vm.warp(EX_PR_PURCHASE_STAMP);
        PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
            value: 3 ether
        }(buyer_01, _wavSaleToken);
    }*/

    // forge test --match-test testPreReleaseSVariantPausedAtBatchAssertion -vvvv

    function testPreReleaseSVariantPausedAtBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );
        }

        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(2),
                    hashId: bytes32(
                        0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(3),
                    hashId: bytes32(
                        0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                    )
                }),
                baseHashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(owner);
        PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        uint8[] memory _pausedAtStates = new uint8[](2);
        _pausedAtStates[0] = uint8(1);
        _pausedAtStates[1] = uint8(1);

        bytes32[] memory _hashIdBatch = new bytes32[](2);
        _hashIdBatch[0] = _creatorTokenVariant[0].creatorToken.hashId;
        _hashIdBatch[1] = _creatorTokenVariant[1].creatorToken.hashId;

        vm.prank(owner);

        PreReleaseStateBatch(address(wavDiamond)).preReleaseStateBatch(
            _hashIdBatch,
            _pausedAtStates
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[0].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[1].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.deal(buyer_01, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer_01, _wavSaleToken);
        }
    }

    // forge test --match-test testWavSaleCContentTokenPostEndReleaseBatchAssertion -vvvv

    function testWavSaleCContentTokenPostEndReleaseBatchAssertion() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        // was both '1' just temporarily modified
        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        // CContentToken[0]
        _creatorToken[0] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(0),
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            )
        });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_01,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_CRELEASE_01
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        // cContentToken[1]
        _creatorToken[1] = CreatorTokenStorage.CreatorToken({
            creatorId: publisher,
            contentId: uint256(1),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_01,
            sPriceUsdVal: EX_SPRICE_USD_01,
            cPriceUsdVal: EX_CPRICE_USD_01,
            sSupplyVal: EX_SSUPPLY_01,
            sReserveVal: EX_SRESERVE_01,
            cReleaseVal: EX_CRELEASE_01
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCContentTokenBatch(address(wavDiamond))
            .publishCContentTokenBatch(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
            );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[0].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken[1].hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }

        uint96[] memory _disablePeriodBatch = new uint96[](2);
        _disablePeriodBatch[0] = uint96(82);
        _disablePeriodBatch[1] = uint96(82);

        bytes32[] memory _hashIdBatch = new bytes32[](2);
        _hashIdBatch[0] = bytes32(
            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
        );
        _hashIdBatch[1] = bytes32(
            0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
        );

        vm.prank(owner);
        PostEndReleaseBatch(address(wavDiamond)).postManualEndReleaseBatch(
            _hashIdBatch,
            _disablePeriodBatch
        );
        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.prank(owner);
            vm.warp(EX_POST_END_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testWavSaleSVariantPostEndReleaseBatchAssertion -vvvv

    function testWavSaleSVariantPostEndReleaseBatchAssertion() public {
        {
            CreatorTokenStorage.CreatorToken[]
                memory _creatorToken = new CreatorTokenStorage.CreatorToken[](
                    2
                );
            SContentTokenStorage.SContentToken[]
                memory _sContentToken = new SContentTokenStorage.SContentToken[](
                    2
                );
            CollaboratorStructStorage.Collaborator[]
                memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                    2
                );

            // CContentToken[0]
            _creatorToken[0] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

            _sContentToken[0] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            _collaborator[0] = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                royaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

            // CContentToken[0]
            _creatorToken[1] = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(1),
                hashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                )
            });

            _sContentToken[1] = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

            _collaborator[1] = _collaborator[0];

            vm.prank(owner);
            PublishSContentTokenBatch(address(wavDiamond))
                .publishSContentTokenBatch(
                    _creatorToken,
                    _sContentToken,
                    _collaborator
                );
        }

        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(2),
                    hashId: bytes32(
                        0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_01),
            releaseVal: uint96(EX_CRELEASE_01)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(3),
                    hashId: bytes32(
                        0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
                    )
                }),
                baseHashId: bytes32(
                    0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
                ),
                variantIndex: uint16(1)
            });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_01),
            releaseVal: uint96(EX_CRELEASE_01)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(owner);
        PublishSVariantBatch(address(wavDiamond)).publishSVariantBatch(
            _creatorTokenVariant,
            _sContentToken,
            _collaborator
        );

        WavSaleToken.WavSale[]
            memory _wavSaleToken = new WavSaleToken.WavSale[](2);

        _wavSaleToken[0] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[0].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _wavSaleToken[1] = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant[1].creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 _totalWei = 0;

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }

        uint96[] memory _disablePeriodBatch = new uint96[](2);
        _disablePeriodBatch[0] = uint96(82);
        _disablePeriodBatch[1] = uint96(82);

        bytes32[] memory _hashIdBatch = new bytes32[](2);
        _hashIdBatch[0] = bytes32(
            0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5
        );
        _hashIdBatch[1] = bytes32(
            0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb
        );

        vm.prank(owner);

        PostEndReleaseBatch(address(wavDiamond)).postManualEndReleaseBatch(
            _hashIdBatch,
            _disablePeriodBatch
        );

        {
            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 _weiZero = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiZero;

            usdVal = 349;
            usd8 = usdVal * 1e6;
            uint256 _weiOne = (usd8 * 1e18) / feedAnswer;
            _totalWei += _weiOne;

            vm.expectRevert();
            vm.prank(owner);
            vm.warp(EX_POST_END_PURCHASE_STAMP);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer_01,
                _wavSaleToken
            );
        }
    }
}
