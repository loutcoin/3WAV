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
    PublishCContentTokenBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";

import {
    PublishSContentTokenBatch
} from "../../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";

import {
    AllocateWavStoreBatch
} from "../../src/3WAVi__ORIGINS/Allocate/AllocateWavStoreBatch.sol";

import {
    AllocateWavReserveBatch
} from "../../src/3WAVi__ORIGINS/Allocate/AllocateWavReserveBatch.sol";

import {WavAccess} from "../../src/3WAVi__ORIGINS/WavAccess.sol";

import {
    ReserveExchangeBatch
} from "../../src/3WAVi__ORIGINS/Sale/ReserveExchangeBatch.sol";

import {WavSaleBatch} from "../../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

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
    ReserveExchangeToken
} from "../../src/Diamond__Storage/ContentToken/SaleTemporaries/ReserveExchangeToken.sol";

import {
    CollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/CollaboratorStructStorage.sol";

import {
    SCollaboratorStructStorage
} from "../../src/Diamond__Storage/ContentToken/Optionals/SCollaboratorStructStorage.sol";

import {ReturnHashId} from "../../src/3WAVi__Helpers/ReturnHashId.sol";

import {MockV3Aggregator} from "../../test/Mock/MockV3Aggregator.t.sol";

import {TestPriceFeedSetter} from "../../test/Mock/TestPriceFeedSetter.t.sol";

import {IDiamondCut} from "../../src/Interfaces/IDiamondCut.sol";

contract AllocateUnallocatedSupplyBatchTest is Test {
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    AllocateWavStoreBatch public allocateWavStoreBatch;
    AllocateWavReserveBatch public allocateWavReserveBatch;
    ReserveExchangeBatch public reserveExchangeBatch;
    WavSaleBatch public wavSaleBatch;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    uint112 constant EX_CSUPPLY_01 = 100000000030000000001000000000000; // TS: 3 | IS: 1 | WR: 0% | PR: 0%
    uint112 constant EX_CSUPPLY_02 = 100000000100000000001000001000000; // TS: 10 | IS: 1 | WR: 10% | PR: 0%
    //                               1000000000200000000000000000000
    //
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,
    uint96 constant EX_PURCHASE_STAMP_01 = 4900570000000000000;
    uint96 constant EX_RESERVE_STAMP = 1764205200;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    address public buyer = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentTokenBatch = new PublishCContentTokenBatch();
        publishSContentTokenBatch = new PublishSContentTokenBatch();
        allocateWavStoreBatch = new AllocateWavStoreBatch();
        allocateWavReserveBatch = new AllocateWavReserveBatch();
        wavSaleBatch = new WavSaleBatch();
        diamondCutFacet = new DiamondCutFacet();
        diamondLoupeFacet = new DiamondLoupeFacet();
        reserveExchangeBatch = new ReserveExchangeBatch();
        wavAccess = new WavAccess();
        priceSetterFacet = new TestPriceFeedSetter();
        MockV3Aggregator _mockAggregator = new MockV3Aggregator(
            8,
            int256(3000 * 10 ** 8)
        );

        // Deploy
        wavDiamond = new WavDiamond(owner, address(diamondCutFacet));

        LibDiamond.FacetCut[] memory _cut = new LibDiamond.FacetCut[](9);

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

        bytes4[] memory _publishSCTBSelectors = new bytes4[](1);
        _publishSCTBSelectors[0] = PublishSContentTokenBatch
            .publishSContentTokenBatch
            .selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTBSelectors
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

        bytes4[] memory _wavSaleBatchSelectors = new bytes4[](2);
        _wavSaleBatchSelectors[0] = WavSaleBatch.wavSaleBatch.selector;
        _wavSaleBatchSelectors[1] = WavSaleBatch.wavAccessBatch.selector;

        _cut[4] = LibDiamond.FacetCut({
            facetAddress: address(wavSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleBatchSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](6);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[2] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[3] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[4] = WavAccess.removeApprovedAddr.selector;
        _wavAccessSelectors[5] = WavAccess.returnHourStamp.selector;

        _cut[5] = LibDiamond.FacetCut({
            facetAddress: address(wavAccess),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavAccessSelectors
        });

        bytes4[] memory _allocateWavStoreBatchSelectors = new bytes4[](1);
        _allocateWavStoreBatchSelectors[0] = AllocateWavStoreBatch
            .allocateUnallocatedToWavStoreBatch
            .selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(allocateWavStoreBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _allocateWavStoreBatchSelectors
        });

        bytes4[] memory _allocateWavReserveBatchSelectors = new bytes4[](1);
        _allocateWavReserveBatchSelectors[0] = AllocateWavReserveBatch
            .allocateUnallocatedToWavReserveBatch
            .selector;

        _cut[7] = LibDiamond.FacetCut({
            facetAddress: address(allocateWavReserveBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _allocateWavReserveBatchSelectors
        });

        bytes4[] memory _reserveExchangeBatchSelectors = new bytes4[](1);
        _reserveExchangeBatchSelectors[0] = ReserveExchangeBatch
            .reserveExchangeBatch
            .selector;

        _cut[8] = LibDiamond.FacetCut({
            facetAddress: address(reserveExchangeBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _reserveExchangeBatchSelectors
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

    // forge test --match-test testAllocateUnallocatedSContentTokenSupplyBatchToWavStore -vvvv

    function testAllocateUnallocatedSContentTokenSupplyBatchToWavStore()
        public
    {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        SCollaboratorStructStorage.SCollaborator[]
            memory _sCollaborator = new SCollaboratorStructStorage.SCollaborator[](
                2
            );

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

        _sCollaborator[0] = SCollaboratorStructStorage.SCollaborator({
            numCollaborator: uint8(0),
            cRoyaltyVal: uint32(0)
        });

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
            releaseVal: uint96(EX_CRELEASE_01)
        });

        _sCollaborator[1] = _sCollaborator[0];

        vm.prank(owner);
        PublishSContentTokenBatch(address(wavDiamond))
            .publishSContentTokenBatch(
                _creatorToken,
                _sContentToken,
                _sCollaborator
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }

        vm.prank(owner);
        AllocateWavStoreBatch(address(wavDiamond))
            .allocateUnallocatedToWavStoreBatch(_wavSaleToken);

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

            vm.prank(owner);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }

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

            vm.prank(owner);
            vm.expectRevert();
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testAllocateUnallocatedCContentTokenSupplyBatchToWavStore -vvvv

    function testAllocateUnallocatedCContentTokenSupplyBatchToWavStore()
        public
    {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

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
            cRoyaltyVal: uint32(0),
            sRoyaltyVal: uint128(0),
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }

        vm.prank(owner);
        AllocateWavStoreBatch(address(wavDiamond))
            .allocateUnallocatedToWavStoreBatch(_wavSaleToken);

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

            vm.prank(owner);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }

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

            vm.prank(owner);
            vm.expectRevert();
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
        }
    }

    // forge test --match-test testAllocateUnallocatedSContentTokenSupplyBatchToWavReserve -vvvv

    function testAllocateUnallocatedSContentTokenSupplyBatchToWavReserve()
        public
    {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
        SCollaboratorStructStorage.SCollaborator[]
            memory _sCollaborator = new SCollaboratorStructStorage.SCollaborator[](
                2
            );

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
            supplyVal: uint112(EX_CSUPPLY_02),
            releaseVal: uint96(EX_CRELEASE_01)
        });

        uint256[] memory _royaltyMap = new uint256[](1);
        _royaltyMap[0] = uint256(0);

        _sCollaborator[0] = SCollaboratorStructStorage.SCollaborator({
            numCollaborator: uint8(0),
            cRoyaltyVal: uint32(0)
        });

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
            supplyVal: uint112(EX_CSUPPLY_02),
            releaseVal: uint96(EX_CRELEASE_01)
        });

        _sCollaborator[1] = _sCollaborator[0];

        vm.prank(owner);
        PublishSContentTokenBatch(address(wavDiamond))
            .publishSContentTokenBatch(
                _creatorToken,
                _sContentToken,
                _sCollaborator
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

        ReserveExchangeToken.ReserveExchange[]
            memory _reserveExchangeToken = new ReserveExchangeToken.ReserveExchange[](
                2
            );

        _reserveExchangeToken[0] = ReserveExchangeToken.ReserveExchange({
            recipient: buyer,
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            ),
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _reserveExchangeToken[1] = ReserveExchangeToken.ReserveExchange({
            recipient: buyer,
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            ),
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        vm.prank(owner);
        vm.warp(EX_RESERVE_STAMP);
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );

        vm.prank(owner);
        AllocateWavReserveBatch(address(wavDiamond))
            .allocateUnallocatedToWavReserveBatch(_wavSaleToken);

        vm.prank(owner);
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );

        vm.prank(owner);
        vm.expectRevert();
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );
    }

    // forge test --match-test testAllocateUnallocatedCContentTokenSupplyBatchToWavReserve -vvvv

    function testAllocateUnallocatedCContentTokenSupplyBatchToWavReserve()
        public
    {
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
            cSupplyVal: EX_CSUPPLY_02,
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
            cRoyaltyVal: uint32(0),
            sRoyaltyVal: uint128(0),
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
            cSupplyVal: EX_CSUPPLY_02,
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

        ReserveExchangeToken.ReserveExchange[]
            memory _reserveExchangeToken = new ReserveExchangeToken.ReserveExchange[](
                2
            );

        _reserveExchangeToken[0] = ReserveExchangeToken.ReserveExchange({
            recipient: buyer,
            hashId: bytes32(
                0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
            ),
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        _reserveExchangeToken[1] = ReserveExchangeToken.ReserveExchange({
            recipient: buyer,
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            ),
            numToken: uint16(0),
            purchaseQuantity: uint112(1)
        });

        vm.prank(owner);
        vm.warp(EX_RESERVE_STAMP);
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );

        vm.prank(owner);
        AllocateWavReserveBatch(address(wavDiamond))
            .allocateUnallocatedToWavReserveBatch(_wavSaleToken);

        vm.prank(owner);
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );

        vm.prank(owner);
        vm.expectRevert();
        ReserveExchangeBatch(address(wavDiamond)).reserveExchangeBatch(
            publisher,
            _reserveExchangeToken
        );
    }
}
