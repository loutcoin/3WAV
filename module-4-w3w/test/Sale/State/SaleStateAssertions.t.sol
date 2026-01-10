// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../../../src/3WAVi__ORIGINS/WavDiamond.sol";
import {
    DiamondCutFacet
} from "../../../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../../../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../../../src/Diamond__Libraries/LibDiamond.sol";

import {
    PublishCContentToken
} from "../../../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";

import {
    PublishSContentToken
} from "../../../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";

import {
    PublishSVariant
} from "../../../src/3WAVi__ORIGINS/Publish/PublishSVariant.sol";

import {WavSale} from "../../../src/3WAVi__ORIGINS/Sale/WavSale.sol";

import {WavAccess} from "../../../src/3WAVi__ORIGINS/WavAccess.sol";

import {
    PreReleaseSale
} from "../../../src/3WAVi__ORIGINS/Sale/PreReleaseSale.sol";

import {
    PreReleaseState
} from "../../../src/3WAVi__ORIGINS/Sale/State/PreReleaseState.sol";

import {
    PostEndRelease
} from "../../../src/3WAVi__ORIGINS/Sale/State/PostEndRelease.sol";

import {
    CreatorTokenStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";

import {
    CreatorTokenVariantStorage
} from "../../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";

import {
    CContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    WavSaleToken
} from "../../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {
    CollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {MockV3Aggregator} from "../../../test/Mock/MockV3Aggregator.t.sol";

import {
    TestPriceFeedSetter
} from "../../../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../../../src/Interfaces/IDiamondCut.sol";

contract SaleStateAssertions is Test {
    error WavSale__InvalidSale();

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
    uint96 constant EX_PR_PURCHASE_STAMP = 1764183600; // '490051' hourStamp
    uint96 constant EX_PR_EARLY_PURCHASE_STAMP = 1764176400; // '490049' hourStamp
    uint96 constant EX_POST_END_PURCHASE_STAMP = 1764540000;

    uint8 constant EX_PR_PAUSED = 1;

    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishSContentToken public publishSContentToken;
    PublishSVariant public publishSVariant;
    WavSale public wavSale;
    WavAccess public wavAccess;
    PreReleaseSale public preReleaseSale;
    PreReleaseState public preReleaseState;
    PostEndRelease public postEndRelease;
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

        publishCContentToken = new PublishCContentToken();
        publishSContentToken = new PublishSContentToken();
        publishSVariant = new PublishSVariant();
        wavSale = new WavSale();
        wavAccess = new WavAccess();
        preReleaseSale = new PreReleaseSale();
        preReleaseState = new PreReleaseState();
        postEndRelease = new PostEndRelease();
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
        bytes4[] memory _publishCCTSelectors = new bytes4[](1);
        _publishCCTSelectors[0] = PublishCContentToken
            .publishCContentToken
            .selector;

        //_publishSelectors[1] = PublishCContentToken.getPublishedInfo.selector;
        _cut[0] = LibDiamond.FacetCut({
            facetAddress: address(publishCContentToken),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCCTSelectors
        });

        bytes4[] memory _publishSCTSelectors = new bytes4[](1);
        _publishSCTSelectors[0] = PublishSContentToken
            .publishSContentToken
            .selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentToken),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTSelectors
        });

        bytes4[] memory _publishSVSelectors = new bytes4[](1);
        _publishSVSelectors[0] = PublishSVariant.publishSVariant.selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariant),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVSelectors
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

        bytes4[] memory _wavSaleSelectors = new bytes4[](2);
        _wavSaleSelectors[0] = WavSale.wavSaleSingle.selector;
        _wavSaleSelectors[1] = WavSale.wavAccess.selector;

        _cut[5] = LibDiamond.FacetCut({
            facetAddress: address(wavSale),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleSelectors
        });

        bytes4[] memory _preReleaseSaleSelectors = new bytes4[](1);
        _preReleaseSaleSelectors[0] = PreReleaseSale
            .preReleasePurchaseSingle
            .selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(preReleaseSale),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _preReleaseSaleSelectors
        });

        bytes4[] memory _preReleaseStateSelectors = new bytes4[](1);
        _preReleaseStateSelectors[0] = PreReleaseState.preReleaseState.selector;

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(preReleaseState),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _preReleaseStateSelectors
        });

        bytes4[] memory _postEndReleaseSelectors = new bytes4[](1);
        _postEndReleaseSelectors[0] = PostEndRelease
            .postManualEndRelease
            .selector;

        _cut[8] = LibDiamond.FacetCut({
            facetAddress: address(postEndRelease),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _postEndReleaseSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](5);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;

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

    // forge test --match-test testWavSaleCContentTokenEndReleaseAssertion -vvvv

    function testWavSaleCContentTokenEndReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
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

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            //vm.expectRevert(abi.encodeWithSignature("WavSale__InvalidSale"));
            vm.expectRevert();
            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(1764219600);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
    }

    // forge test --match-test testWavSaleCContentTokenEndReleaseAssertion -vvvv
    function testWavSaleSVariantEndReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_END_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_END_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);

            vm.expectRevert();

            vm.prank(owner);
            vm.warp(1764219600);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
    }

    // forge test --match-test testWavSaleCContentTokenPreReleaseActiveAssertion -vvvv

    function testWavSaleCContentTokenPreReleaseActiveAssertion() public {
        CreatorTokenStorage.CreatorToken
            memory _creatorToken = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

        CContentTokenStorage.CContentToken
            memory _cContentToken = CContentTokenStorage.CContentToken({
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

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                cRoyaltyVal: uint32(0),
                sRoyaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); //0101010101100100;

        vm.prank(owner);
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );

        WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        //vm.expectRevert(abi.encodeWithSignature("WavSale__InvalidSale"));
        vm.expectRevert();
        vm.deal(buyer_01, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP);
        WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
            buyer_01,
            _wavSale
        );
    }

    // forge test --match-test testWavSaleSVariantPreReleaseActiveAssertion -vvvv

    function testWavSaleSVariantPreReleaseActiveAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.expectRevert();
            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
    }

    // forge test --match-test testPreReleaseCContentTokenStartReleaseAssertion -vvvv

    function testPreReleaseCContentTokenStartReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
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

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);

            //vm.expectRevert(abi.encodeWithSignature("WavSale__InvalidSale"));
            vm.expectRevert();

            vm.prank(owner);
            vm.warp(1764219600);
            PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
                value: expectedWei
            }(buyer_01, _wavSale);
        }
    }

    // forge test --match-test testPreReleaseSVariantStartReleaseAssertion -vvvv

    function testPreReleaseSVariantStartReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);

            vm.expectRevert();
            vm.prank(owner);
            vm.warp(1764219600);
            PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
                value: expectedWei
            }(buyer_01, _wavSale);
        }
    }

    // forge test --match-test testPreReleaseCContentTokenEarlySaleAssertion -vvvv

    function testPreReleaseCContentTokenEarlySaleAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
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

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            //vm.expectRevert(abi.encodeWithSignature("WavSale__InvalidSale"));
            vm.expectRevert();
            //vm.hoax(buyer_01, 10 ether);
            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PR_EARLY_PURCHASE_STAMP);
            PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
                value: expectedWei
            }(buyer_01, _wavSale);
        }
    }

    // forge test --match-test testPreReleaseSVariantEarlySaleAssertion -vvvv

    function testPreReleaseSVariantEarlySaleAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.expectRevert();
            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PR_EARLY_PURCHASE_STAMP);
            PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
                value: expectedWei
            }(buyer_01, _wavSale);
        }
    }

    // forge test --match-test testPreReleaseCContentTokenPausedAtAssertion -vvvv

    function testPreReleaseCContentTokenPausedAtAssertion() public {
        CreatorTokenStorage.CreatorToken
            memory _creatorToken = CreatorTokenStorage.CreatorToken({
                creatorId: publisher,
                contentId: uint256(0),
                hashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                )
            });

        CContentTokenStorage.CContentToken
            memory _cContentToken = CContentTokenStorage.CContentToken({
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

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(0),
                cRoyaltyVal: uint32(0),
                sRoyaltyVal: uint128(0),
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); //0101010101100100;

        vm.prank(owner);
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );

        vm.prank(owner);

        PreReleaseState(address(wavDiamond)).preReleaseState(
            _creatorToken.hashId,
            EX_PR_PAUSED
        );

        WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        //vm.expectRevert(abi.encodeWithSignature("WavSale__InvalidSale"));
        //vm.hoax(buyer_01, 10 ether);
        vm.expectRevert();
        vm.deal(buyer_01, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP);
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer_01, _wavSale);
    }

    // forge test --match-test testPreReleaseCContentTokenPausedAtAssertion -vvvv

    function testPreReleaseSVariantPausedAtAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_PR),
                    releaseVal: uint96(EX_RELEASE_STAMP_PR)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        CreatorTokenVariantStorage.CreatorTokenVariant
            memory _creatorTokenVariant = CreatorTokenVariantStorage
                .CreatorTokenVariant({
                    creatorToken: CreatorTokenStorage.CreatorToken({
                        creatorId: publisher,
                        contentId: uint256(1),
                        hashId: bytes32(
                            0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                        )
                    }),
                    baseHashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    ),
                    variantIndex: uint16(1)
                });

        SContentTokenStorage.SContentToken
            memory _sContentToken = SContentTokenStorage.SContentToken({
                numToken: uint16(8),
                priceUsdVal: uint32(EX_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_PR),
                releaseVal: uint96(EX_RELEASE_STAMP_PR)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
                numCollaborator: uint8(0),
                cRoyaltyVal: uint32(0)
            });

        vm.prank(owner);
        PublishSVariant(address(wavDiamond)).publishSVariant(
            _creatorTokenVariant,
            _sContentToken,
            _sCollaborator
        );

        vm.prank(owner);

        PreReleaseState(address(wavDiamond)).preReleaseState(
            _creatorTokenVariant.creatorToken.hashId,
            EX_PR_PAUSED
        );

        WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
            creatorId: publisher,
            hashId: _creatorTokenVariant.creatorToken.hashId,
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        uint256 feedAnswer = uint256(3000 * 10 ** 8);
        uint256 usdVal = 349; // 3.49$
        uint256 usd8 = usdVal * 1e6;
        uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

        vm.expectRevert();
        vm.deal(buyer_01, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP);
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer_01, _wavSale);
    }

    // forge test --match-test testWavSaleCContentTokenPostEndReleaseAssertion -vvvv

    function testWavSaleCContentTokenPostEndReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            CContentTokenStorage.CContentToken
                memory _cContentToken = CContentTokenStorage.CContentToken({
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

            CollaboratorStructStorage.Collaborator
                memory _collaborator = CollaboratorStructStorage.Collaborator({
                    numCollaborator: uint8(0),
                    cRoyaltyVal: uint32(0),
                    sRoyaltyVal: uint128(0),
                    royaltyMap: _royaltyMap
                });

            uint256[] memory _tierMapPages = new uint256[](1);
            _tierMapPages[0] = uint256(0x058885580); //01011000100010000101010110000000;

            uint256[] memory _priceMapPages = new uint256[](1);
            _priceMapPages[0] = uint256(0x5564); //0101010101100100;

            vm.prank(owner);
            PublishCContentToken(address(wavDiamond)).publishCContentToken(
                _creatorToken,
                _cContentToken,
                _collaborator,
                _tierMapPages,
                _priceMapPages
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );

            // NEED to change 'cReleaseValEncoder6' to still encode even if hourStamp is greater than '_hourStamp'
            // BECAUSE otherwise after something is in active sale the data cannot even be decoded anymore, haha
            vm.prank(owner);

            PostEndRelease(address(wavDiamond)).postManualEndRelease(
                _creatorToken.hashId,
                82
            );

            vm.expectRevert();
            vm.prank(owner);
            vm.warp(EX_POST_END_PURCHASE_STAMP);
            // Is returning '49014' instead of '490104' for instance, while _startRelease == 490056. While the test is "passing,"
            // This is incorrect in function and needs correction
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
            // From terminal seems to be something that happens AFTER postEndRelease, possibly / likely during greater wavSaleSingle execution
        }
    }

    // forge test --match-test testWavSaleSVariantPostEndReleaseAssertion -vvvv

    function testWavSaleSVariantPostEndReleaseAssertion() public {
        {
            CreatorTokenStorage.CreatorToken
                memory _creatorToken = CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSContentToken(address(wavDiamond)).publishSContentToken(
                _creatorToken,
                _sContentToken,
                _sCollaborator
            );
        }
        {
            CreatorTokenVariantStorage.CreatorTokenVariant
                memory _creatorTokenVariant = CreatorTokenVariantStorage
                    .CreatorTokenVariant({
                        creatorToken: CreatorTokenStorage.CreatorToken({
                            creatorId: publisher,
                            contentId: uint256(1),
                            hashId: bytes32(
                                0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec
                            )
                        }),
                        baseHashId: bytes32(
                            0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                        ),
                        variantIndex: uint16(1)
                    });

            SContentTokenStorage.SContentToken
                memory _sContentToken = SContentTokenStorage.SContentToken({
                    numToken: uint16(8),
                    priceUsdVal: uint32(EX_CPRICE_USD_01),
                    supplyVal: uint112(EX_CSUPPLY_01),
                    releaseVal: uint96(EX_CRELEASE_01)
                });

            uint256[] memory _royaltyMap = new uint256[](1);
            _royaltyMap[0] = uint256(0);

            SCollaboratorStructStorage.SCollaborator
                memory _sCollaborator = SCollaboratorStructStorage
                    .SCollaborator({
                        numCollaborator: uint8(0),
                        cRoyaltyVal: uint32(0)
                    });

            vm.prank(owner);
            PublishSVariant(address(wavDiamond)).publishSVariant(
                _creatorTokenVariant,
                _sContentToken,
                _sCollaborator
            );

            WavSaleToken.WavSale memory _wavSale = WavSaleToken.WavSale({
                creatorId: publisher,
                hashId: _creatorTokenVariant.creatorToken.hashId,
                numToken: uint16(0),
                purchaseQuantity: uint112(1)
            });

            uint256 feedAnswer = uint256(3000 * 10 ** 8);
            uint256 usdVal = 349; // 3.49$
            uint256 usd8 = usdVal * 1e6;
            uint256 expectedWei = (usd8 * 1e18) / feedAnswer;

            vm.deal(buyer_01, 10 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );

            vm.prank(owner);

            PostEndRelease(address(wavDiamond)).postManualEndRelease(
                _creatorTokenVariant.creatorToken.hashId,
                82
            );

            vm.expectRevert();
            vm.prank(owner);
            vm.warp(EX_POST_END_PURCHASE_STAMP);
            WavSale(address(wavDiamond)).wavSaleSingle{value: expectedWei}(
                buyer_01,
                _wavSale
            );
        }
    }

    // 490140 * 3600 = 1764504000
    // 490150 * 3600 = 1764540000
}
