// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";
import {console} from "lib/forge-std/src/console.sol";
import {WavDiamond} from "../src/3WAVi__ORIGINS/WavDiamond.sol";
import {DiamondCutFacet} from "../src/Diamond__ProxyFacets/DiamondCutFacet.sol";
import {
    DiamondLoupeFacet
} from "../src/Diamond__ProxyFacets/DiamondLoupeFacet.sol";
import {
    PublishCContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCContentTokenBatch.sol";
import {
    PublishCVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishCVariantBatch.sol";
import {
    PublishSContentTokenBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSContentTokenBatch.sol";
import {
    PublishSVariantBatch
} from "../src/3WAVi__ORIGINS/Publish/PublishSVariantBatch.sol";
import {LibDiamond} from "../src/Diamond__Libraries/LibDiamond.sol";
import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";
import {
    PreReleaseSaleBatch
} from "../src/3WAVi__ORIGINS/Sale/PreReleaseSaleBatch.sol";
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
import {ReturnHashId} from "../src/3WAVi__Helpers/ReturnHashId.sol";
import {MockV3Aggregator} from "../test/Mock/MockV3Aggregator.t.sol";
import {TestPriceFeedSetter} from "../test/Mock/TestPriceFeedSetter.t.sol";
import {IDiamondCut} from "../src/Interfaces/IDiamondCut.sol";

contract PreReleaseSaleTokenBatch is Test {
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishCVariantBatch public publishCVariantBatch;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    PublishSVariantBatch public publishSVariantBatch;
    PreReleaseSaleBatch public preReleaseSaleBatch;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    address public buyer = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    uint112 constant EX_CSUPPLY_PR = 100000099990000000999100000100000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_SPRICE_USD = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_RELEASE_STAMP_PR = 4900560000004900500; // get UNIX stamp, / 3600, use vm.warp
    uint96 constant EX_PURCHASE_STAMP_PR = 4900560000004900510;

    uint96 constant EX_PR_PURCHASE_STAMP = 1764183600;

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentTokenBatch = new PublishCContentTokenBatch();
        publishCVariantBatch = new PublishCVariantBatch();
        publishSContentTokenBatch = new PublishSContentTokenBatch();
        publishSVariantBatch = new PublishSVariantBatch();
        preReleaseSaleBatch = new PreReleaseSaleBatch();
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
        bytes4[] memory _publishCCTBSelectors = new bytes4[](1);
        _publishCCTBSelectors[0] = PublishCContentTokenBatch
            .publishCContentTokenBatch
            .selector;

        _cut[0] = LibDiamond.FacetCut({
            facetAddress: address(publishCContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCCTBSelectors
        });

        bytes4[] memory _publishCVBSelectors = new bytes4[](2);
        _publishCVBSelectors[0] = PublishCVariantBatch
            .publishCVariantBatch
            .selector;
        _publishCVBSelectors[1] = PublishCVariantBatch
            .publishCContentTokenVariantBatch
            .selector;

        _cut[1] = LibDiamond.FacetCut({
            facetAddress: address(publishCVariantBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishCVBSelectors
        });

        bytes4[] memory _publishSCTBSelectors = new bytes4[](1);
        _publishSCTBSelectors[0] = PublishSContentTokenBatch
            .publishSContentTokenBatch
            .selector;

        _cut[2] = LibDiamond.FacetCut({
            facetAddress: address(publishSContentTokenBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSCTBSelectors
        });

        bytes4[] memory _publishSVBSelectors = new bytes4[](2);
        _publishSVBSelectors[0] = PublishSVariantBatch
            .publishSVariantBatch
            .selector;
        _publishSVBSelectors[1] = PublishSVariantBatch
            .publishSContentTokenVariantBatch
            .selector;

        _cut[3] = LibDiamond.FacetCut({
            facetAddress: address(publishSVariantBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _publishSVBSelectors
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

        bytes4[] memory _preReleaseSaleBatchSelectors = new bytes4[](1);
        _preReleaseSaleBatchSelectors[0] = PreReleaseSaleBatch
            .preReleasePurchaseBatch
            .selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(preReleaseSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _preReleaseSaleBatchSelectors
        });

        bytes4[] memory _wavAccessSelectors = new bytes4[](6);
        _wavAccessSelectors[0] = WavAccess.returnOwnership.selector;
        _wavAccessSelectors[1] = WavAccess.returnOwnership2.selector;
        _wavAccessSelectors[2] = WavAccess.returnOwnershipIndex.selector;
        _wavAccessSelectors[3] = WavAccess.addOwnerAddr.selector;
        _wavAccessSelectors[4] = WavAccess.addApprovedAddr.selector;
        _wavAccessSelectors[5] = WavAccess.removeApprovedAddr.selector;

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

    // forge test --match-test testPreReleaseSaleCContentTokenBatchHappyPath -vvvv

    function testPreReleaseSaleCContentTokenBatchHappyPath() public {
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
            sPriceUsdVal: EX_SPRICE_USD,
            cPriceUsdVal: EX_CPRICE_USD,
            sSupplyVal: EX_SSUPPLY,
            sReserveVal: EX_SRESERVE,
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
            sPriceUsdVal: EX_SPRICE_USD,
            cPriceUsdVal: EX_CPRICE_USD,
            sSupplyVal: EX_SSUPPLY,
            sReserveVal: EX_SRESERVE,
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    function testPreReleaseSaleCVariantBatchHappyPath() public {
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
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
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
                sPriceUsdVal: EX_SPRICE_USD,
                cPriceUsdVal: EX_CPRICE_USD,
                sSupplyVal: EX_SSUPPLY,
                sReserveVal: EX_SRESERVE,
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
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

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

        _cContentToken[0] = CContentTokenStorage.CContentToken({
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

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

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

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD,
            cPriceUsdVal: EX_CPRICE_USD,
            sSupplyVal: EX_SSUPPLY,
            sReserveVal: EX_SRESERVE,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCVariantBatch(address(wavDiamond)).publishCVariantBatch(
            _creatorTokenVariant,
            _cContentToken,
            _collaborator,
            _tierPages,
            _pricePages
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    function testPreReleaseSaleCContentTokenVariantBatchHappyPath() public {
        CreatorTokenVariantStorage.CreatorTokenVariant[]
            memory _creatorTokenVariant = new CreatorTokenVariantStorage.CreatorTokenVariant[](
                2
            );
        CContentTokenStorage.CContentToken[]
            memory _cContentToken = new CContentTokenStorage.CContentToken[](2);
        CollaboratorStructStorage.Collaborator[]
            memory _collaborator = new CollaboratorStructStorage.Collaborator[](
                2
            );

        uint256[] memory _tierPages = new uint256[](2);
        uint256[] memory _pricePages = new uint256[](2);

        _creatorTokenVariant[0] = CreatorTokenVariantStorage
            .CreatorTokenVariant({
                creatorToken: CreatorTokenStorage.CreatorToken({
                    creatorId: publisher,
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(0)
            });

        _cContentToken[0] = CContentTokenStorage.CContentToken({
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

        _collaborator[0] = CollaboratorStructStorage.Collaborator({
            numCollaborator: uint8(0),
            royaltyVal: uint128(0),
            royaltyMap: _royaltyMap
        });

        _tierPages[0] = uint256(0x058885580);
        _pricePages[0] = uint256(0x5564);

        _creatorTokenVariant[1] = CreatorTokenVariantStorage
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

        _cContentToken[1] = CContentTokenStorage.CContentToken({
            numToken: uint16(8),
            cSupplyVal: EX_CSUPPLY_PR,
            sPriceUsdVal: EX_SPRICE_USD,
            cPriceUsdVal: EX_CPRICE_USD,
            sSupplyVal: EX_SSUPPLY,
            sReserveVal: EX_SRESERVE,
            cReleaseVal: EX_RELEASE_STAMP_PR
        });

        _collaborator[1] = _collaborator[0];

        _tierPages[1] = uint256(0x058885580);
        _pricePages[1] = uint256(0x5564);

        vm.prank(owner);
        PublishCVariantBatch(address(wavDiamond))
            .publishCContentTokenVariantBatch(
                _creatorTokenVariant,
                _cContentToken,
                _collaborator,
                _tierPages,
                _pricePages
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    // forge test --match-test testPreReleaseSaleSContentTokenBatchHappyPath -vvvv

    function testPreReleaseSaleSContentTokenBatchHappyPath() public {
        CreatorTokenStorage.CreatorToken[]
            memory _creatorToken = new CreatorTokenStorage.CreatorToken[](2);
        SContentTokenStorage.SContentToken[]
            memory _sContentToken = new SContentTokenStorage.SContentToken[](2);
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
            priceUsdVal: uint32(EX_CPRICE_USD),
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
            contentId: uint256(0),
            hashId: bytes32(
                0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261
            )
        });

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD),
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
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    function testPreReleaseSaleSVariantBatchHappyPath() public {
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
                priceUsdVal: uint32(EX_CPRICE_USD),
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
                priceUsdVal: uint32(EX_CPRICE_USD),
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
            priceUsdVal: uint32(EX_CPRICE_USD),
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
            priceUsdVal: uint32(EX_CPRICE_USD),
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }

    function testPreReleaseSaleSContentTokenVariantBatchHappyPath() public {
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
                    contentId: uint256(0),
                    hashId: bytes32(
                        0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                    )
                }),
                baseHashId: bytes32(
                    0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df
                ),
                variantIndex: uint16(0)
            });

        _sContentToken[0] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD),
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

        _sContentToken[1] = SContentTokenStorage.SContentToken({
            numToken: uint16(8),
            priceUsdVal: uint32(EX_CPRICE_USD),
            supplyVal: uint112(EX_CSUPPLY_PR),
            releaseVal: uint96(EX_RELEASE_STAMP_PR)
        });

        _collaborator[1] = _collaborator[0];

        vm.prank(owner);
        PublishSVariantBatch(address(wavDiamond))
            .publishSContentTokenVariantBatch(
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PR_PURCHASE_STAMP);
            PreReleaseSaleBatch(address(wavDiamond)).preReleasePurchaseBatch{
                value: _totalWei
            }(buyer, _wavSaleToken);
        }

        bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);
        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);
        for (uint256 w = 0; w < 8 && w * 32 < ret.length; ++w) {
            bytes32 word;
            assembly {
                word := mload(add(ret, add(32, mul(32, w))))
            }
            console.logUint(w);
            console.logBytes32(word);
        }
    }
}
