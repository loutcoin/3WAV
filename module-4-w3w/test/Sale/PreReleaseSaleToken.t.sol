// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../../src/3WAVi__ORIGINS/WavDiamond.sol";
import {
    DiamondCutFacet
} from "../../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {LibDiamond} from "../../src/Diamond__Libraries/LibDiamond.sol";
import {
    PublishCContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";
import {
    PublishCVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishCVariant.sol";
import {
    PublishSContentToken
} from "../../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";
import {
    PublishSVariant
} from "../../src/3WAVi__ORIGINS/Publish/PublishSVariant.sol";
import {WavAccess} from "../../src/3WAVi__ORIGINS/WavAccess.sol";
import {PreReleaseSale} from "../../src/3WAVi__ORIGINS/Sale/PreReleaseSale.sol";
import {
    CreatorTokenStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenStorage.sol";
import {
    CreatorTokenVariantStorage
} from "../../src/Diamond__Storage/CreatorToken/CreatorTokenVariantStorage.sol";
import {
    CContentTokenStorage
} from "../../src/Diamond__Storage/ContentToken/CContentTokenStorage.sol";

import {
    SContentTokenStorage
} from "../../src/Diamond__Storage/ContentToken/SContentTokenStorage.sol";

import {
    WavSaleToken
} from "../../src/Diamond__Storage/ContentToken/SaleTemporaries/WavSaleToken.sol";

import {
    SCollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {
    CollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {ReturnHashId} from "../../src/3WAVi__Helpers/ReturnHashId.sol";

import {MockV3Aggregator} from "../../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../../src/Interfaces/IDiamondCut.sol";

contract PreReleaseSaleToken is Test {
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishCVariant public publishCVariant;
    PublishSContentToken public publishSContentToken;
    PublishSVariant public publishSVariant;
    PreReleaseSale public preReleaseSale;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    address public buyer = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    uint112 constant EX_CSUPPLY_PR = 100000099990000000999100000100000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 10%
    uint112 constant EX_SPRICE_USD = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_RELEASE_STAMP_PR = 4900560000004900500; // get UNIX stamp, / 3600, use vm.warp
    uint96 constant EX_PURCHASE_STAMP_PR = 4900560000004900510;

    uint96 constant EX_PR_PURCHASE_STAMP = 1764183600; // '490051' hourStamp

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentToken = new PublishCContentToken();
        publishCVariant = new PublishCVariant();
        publishSContentToken = new PublishSContentToken();
        publishSVariant = new PublishSVariant();
        preReleaseSale = new PreReleaseSale();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        wavAccess = new WavAccess();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        // Build the cut array (which facet selectors to include)
        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](8);

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

        bytes4[] memory _publishCVSelectors = new bytes4[](1);
        _publishCVSelectors[0] = PublishCVariant.publishCVariant.selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishCVariant),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCVSelectors
        });

        bytes4[] memory _publishSCTSelectors = new bytes4[](1);
        _publishSCTSelectors[0] = PublishSContentToken
            .publishSContentToken
            .selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentToken),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTSelectors
        });

        bytes4[] memory _publishSVSelectors = new bytes4[](1);
        _publishSVSelectors[0] = PublishSVariant.publishSVariant.selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariant),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVSelectors
        });

        bytes4[] memory _loupeSelectors = new bytes4[](3);
        _loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        _loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        _loupeSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        _cut[4] = LibDiamond.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _loupeSelectors
        });

        bytes4[] memory _setterSelectors = new bytes4[](1);
        _setterSelectors[0] = TestPriceFeedSetter.setPriceFeed.selector;

        _cut[5] = LibDiamond.FacetCut({
            facetAddress: address(priceSetterFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _setterSelectors
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

        bytes4[] memory _wavAccessSelectors = new bytes4[](5);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;

        _cut[7] = LibDiamond.FacetCut({
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

    // "hourStamp: 1361266666668027"

    function testPreReleaseSaleCContentTokenHappyPath() public {
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
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
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

        vm.deal(buyer, 10 ether);
        uint256 initialBalance = buyer.balance;
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP); //EX_PURCHASE_STAMP_PR, 4900560000004900510 * 3600 == 1764183600
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer, _wavSale);

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer,
            0
        );
    }

    function testPreReleaseSaleCVariantHappyPath() public {
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
                    sPriceUsdVal: EX_SPRICE_USD,
                    cPriceUsdVal: EX_CPRICE_USD,
                    sSupplyVal: EX_SSUPPLY,
                    sReserveVal: EX_SRESERVE,
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

        CContentTokenStorage.CContentToken
            memory _cContentToken = CContentTokenStorage.CContentToken({
                numToken: uint16(8),
                cSupplyVal: EX_CSUPPLY_PR,
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
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
        PublishCVariant(address(wavDiamond)).publishCVariant(
            _creatorTokenVariant,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
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

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP); //EX_PURCHASE_STAMP_PR, 4900560000004900510 * 3600 == 1764183600
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer, _wavSale);

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer,
            0
        );
    }

    function testPreReleaseSaleSContentTokenHappyPath() public {
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
                priceUsdVal: uint32(EX_CPRICE_USD),
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
        PublishSContentToken(address(wavDiamond)).publishSContentToken(
            _creatorToken,
            _sContentToken,
            _sCollaborator
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

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP); //EX_PURCHASE_STAMP_PR, 4900560000004900510 * 3600 == 1764183600
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer, _wavSale);

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer,
            0
        );
    }

    function testPreReleaseSaleSVariantHappyPath() public {
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
                    priceUsdVal: uint32(EX_CPRICE_USD),
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
                priceUsdVal: uint32(EX_CPRICE_USD),
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

        vm.deal(buyer, 10 ether);
        vm.prank(owner);
        vm.warp(EX_PR_PURCHASE_STAMP); //EX_PURCHASE_STAMP_PR, 4900560000004900510 * 3600 == 1764183600
        PreReleaseSale(address(wavDiamond)).preReleasePurchaseSingle{
            value: expectedWei
        }(buyer, _wavSale);

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnershipIndex.selector,
            buyer,
            0
        );
    }
}
