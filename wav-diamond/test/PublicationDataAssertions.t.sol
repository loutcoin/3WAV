// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";

import {console} from "lib/forge-std/src/console.sol";

import {WavDiamond} from "../src/3WAVi__ORIGINS/WavDiamond.sol";

import {DiamondCutFacet} from "../src/Diamond__ProxyFacets/DiamondCutFacet.sol";

import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";

import {LibDiamond} from "../src/Diamond__Libraries/LibDiamond.sol";

import {
    PublishCContentToken
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentToken.sol";

import {
    PublishSContentToken
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentToken.sol";

import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";

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
    CollaboratorStructStorage
} from "../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    SCollaboratorStructStorage
} from "../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../src/Interfaces/IDiamondCut.sol";

contract PublicationDataAssertions is Test {
    event Test(bool _success);

    uint112 constant EX_CSUPPLY_01 = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_CSUPPLY_PR = 100000099990000000999100000100000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 10%
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,

    uint128 constant EX_SROYALTY_VAL = 100050000000000000000000000000000000000;
    uint128 constant EX_SROYALTY_VAL_02 =
        100050000100000050000100000050000100000;

    uint112 constant EX_EXCESSIVE_CSUPPLY_01 =
        1000000999900000009991000000000000; // Added additional digit
    uint112 constant EX_INSUFFICIENT_CSUPPLY_01 =
        10000009999000000099910000000000; // Removed one digit

    uint112 constant EX_EXCESSIVE_SPRICE_USD_01 =
        1000000000740000000690000000000; // Added additional digit
    uint112 constant EX_INSUFFICIENT_SPRICE_USD_01 =
        10000000007400000006900000000; // Removed one digit

    // "EX_EXCESSIVE_CPRICE_USD_01" is protected as any number greater than maximum exceeds max(uint32)
    uint32 constant EX_INSUFFICIENT_CPRICE_USD_01 = 100000349; // Removed one digit

    uint224 constant EX_EXCESSIVE_SSUPPLY_01 =
        1000000000999000000088800000000000000000333000000029600000000000; // Added additional digit
    uint224 constant EX_INSUFFICIENT_SSUPPLY_01 =
        10000000009990000000888000000000000000003330000000296000000000; // Removed one digit

    uint160 constant EX_EXCESSIVE_SRESERVE_01 =
        1000500000000000000000000000000000000000; // Added additional digit
    uint160 constant EX_EXCESSIVE_SRESERVE_02 =
        199050000000000000000000000000000000000;
    uint160 constant EX_INSUFFICIENT_SRESERVE_01 =
        10005000000000000000000000000000000000; // Removed one digit

    uint96 constant EX_EXCESSIVE_CRELEASE_01 = 49005649006000000000; // Added additional digit
    uint96 constant EX_INSUFFICIENT_CRELEASE_01 = 490056490060000000; // Removed one digit

    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentToken public publishCContentToken;
    PublishSContentToken public publishSContentToken;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentToken = new PublishCContentToken();
        publishSContentToken = new PublishSContentToken();
        wavAccess = new WavAccess();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        // Build the cut array (which facet selectors to include)
        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](5);

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

        bytes4[] memory _loupeSelectors = new bytes4[](3);
        _loupeSelectors[0] = DiamondLoupeFacet.facets.selector;
        _loupeSelectors[1] = DiamondLoupeFacet.facetFunctionSelectors.selector;
        _loupeSelectors[2] = DiamondLoupeFacet.facetAddresses.selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(diamondLoupeFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _loupeSelectors
        });

        bytes4[] memory _setterSelectors = new bytes4[](1);
        _setterSelectors[0] = TestPriceFeedSetter.setPriceFeed.selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(priceSetterFacet),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _setterSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](5);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;

        _cut[4] = LibDiamond.FacetCut({
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

    // forge test --match-test testCContentTokenExcessiveCSupplyValPublication -vvvv

    function testCContentTokenExcessiveCSupplyValPublication() public {
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
                cSupplyVal: EX_EXCESSIVE_CSUPPLY_01,
                sPriceUsdVal: EX_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testSContentTokenInsufficientCSupplyValPublication -vvvv

    function testSContentTokenInsufficientCSupplyValPublication() public {
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
                supplyVal: uint112(EX_INSUFFICIENT_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
                numCollaborator: uint8(2),
                cRoyaltyVal: uint32(1100000)
            });

        vm.prank(owner);
        vm.expectRevert();
        PublishSContentToken(address(wavDiamond)).publishSContentToken(
            _creatorToken,
            _sContentToken,
            _sCollaborator
        );
    }

    // forge test --match-test testCContentTokenExcessiveSPriceUsdValPublication -vvvv

    function testCContentTokenExcessiveSPriceUsdValPublication() public {
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
                sPriceUsdVal: EX_EXCESSIVE_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenInsufficientSPriceUsdValPublication

    function testCContentTokenInsufficientSPriceUsdValPublication() public {
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
                sPriceUsdVal: EX_INSUFFICIENT_SPRICE_USD_01,
                cPriceUsdVal: EX_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenInsufficientCPriceUsdValPublication -vvvv

    function testCContentTokenInsufficientCPriceUsdValPublication() public {
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
                cPriceUsdVal: EX_INSUFFICIENT_CPRICE_USD_01,
                sSupplyVal: EX_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testSContentTokenInsufficientCPriceUsdValPublication -vvvv

    function testSContentTokenInsufficientCPriceUsdValPublication() public {
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
                priceUsdVal: uint32(EX_INSUFFICIENT_CPRICE_USD_01),
                supplyVal: uint112(EX_CSUPPLY_01),
                releaseVal: uint96(EX_CRELEASE_01)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
                numCollaborator: uint8(2),
                cRoyaltyVal: uint32(1100000)
            });

        vm.prank(owner);
        vm.expectRevert();
        PublishSContentToken(address(wavDiamond)).publishSContentToken(
            _creatorToken,
            _sContentToken,
            _sCollaborator
        );
    }

    // forge test --match-test testCContentTokenExcessiveSSupplyValPublication -vvvv

    function testCContentTokenExcessiveSSupplyValPublication() public {
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
                sSupplyVal: EX_EXCESSIVE_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenInsufficientSSupplyValPublication -vvvv

    function testCContentTokenInsufficientSSupplyValPublication() public {
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
                sSupplyVal: EX_INSUFFICIENT_SSUPPLY_01,
                sReserveVal: EX_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenExcessiveSReserveValPublication -vvvv

    function testCContentTokenExcessiveSReserveValPublication() public {
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
                sReserveVal: EX_EXCESSIVE_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenInvalidSReserveValZeroValPublication -vvvv

    function testCContentTokenInvalidSReserveValZeroValPublication() public {
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
                sReserveVal: EX_EXCESSIVE_SRESERVE_02,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenInsufficientSReserveValPublication -vvvv

    function testCContentTokenInsufficientSReserveValPublication() public {
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
                sReserveVal: EX_INSUFFICIENT_SRESERVE_01,
                cReleaseVal: EX_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testCContentTokenExcessiveCReleaseValPublication -vvvv

    function testCContentTokenExcessiveCReleaseValPublication() public {
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
                cReleaseVal: EX_EXCESSIVE_CRELEASE_01
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0x201248);

        CollaboratorStructStorage.Collaborator
            memory _collaborator = CollaboratorStructStorage.Collaborator({
                numCollaborator: uint8(3),
                cRoyaltyVal: uint32(1100000),
                sRoyaltyVal: EX_SROYALTY_VAL,
                royaltyMap: _royaltyMap
            });

        uint256[] memory _tierMapPages = new uint256[](1);
        _tierMapPages[0] = uint256(0x058885580); // 10-01011000100010000101010110000000

        uint256[] memory _priceMapPages = new uint256[](1);
        _priceMapPages[0] = uint256(0x5564); // 1-00101010101100100

        vm.prank(owner);
        vm.expectRevert();
        PublishCContentToken(address(wavDiamond)).publishCContentToken(
            _creatorToken,
            _cContentToken,
            _collaborator,
            _tierMapPages,
            _priceMapPages
        );
    }

    // forge test --match-test testSContentTokenInsufficientCReleaseValPublication -vvvv

    function testSContentTokenInsufficientCReleaseValPublication() public {
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
                releaseVal: uint96(EX_INSUFFICIENT_CRELEASE_01)
            });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        SCollaboratorStructStorage.SCollaborator
            memory _sCollaborator = SCollaboratorStructStorage.SCollaborator({
                numCollaborator: uint8(2),
                cRoyaltyVal: uint32(1100000)
            });

        vm.prank(owner);
        vm.expectRevert();
        PublishSContentToken(address(wavDiamond)).publishSContentToken(
            _creatorToken,
            _sContentToken,
            _sCollaborator
        );
    }
}
