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

import {WavAccess} from "../src/3WAVi__ORIGINS/WavAccess.sol";

import {WavSaleBatch} from "../src/3WAVi__ORIGINS/Sale/WavSaleBatch.sol";

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

contract WavSaleTokenBatchTest is Test {
    event success101(bool _success);
    event success102(bool _success);
    WavDiamond public wavDiamond;
    DiamondCutFacet public diamondCutFacet;
    DiamondLoupeFacet public diamondLoupeFacet;
    PublishCContentTokenBatch public publishCContentTokenBatch;
    PublishCVariantBatch public publishCVariantBatch;
    PublishSContentTokenBatch public publishSContentTokenBatch;
    PublishSVariantBatch public publishSVariantBatch;
    WavSaleBatch public wavSaleBatch;
    WavAccess public wavAccess;
    TestPriceFeedSetter public priceSetterFacet;

    uint112 constant EX_CSUPPLY_01 = 100000099990000000999100000000000; // TS: 9,999 | IS: 999 | WR: 10% | PR: 0%
    uint112 constant EX_SPRICE_USD_01 = 100000000074000000069000000000; // SP: 0.74$ | AP: 0.69$
    uint32 constant EX_CPRICE_USD_01 = 1000000349; // 3.49$
    uint224 constant EX_SSUPPLY_01 =
        100000000099900000008880000000000000000033300000002960000000000; // TS1: 999 | TS2: 888 | IS1: 333 | IS2: 296
    uint160 constant EX_SRESERVE_01 = 100050000000000000000000000000000000000; // WR1: 5%
    uint96 constant EX_CRELEASE_01 = 4900560000000000000; // get UNIX stamp, / 3600, use vm.warp // is returning 7 digit integer,
    // 4900560 INSTEAD OF 490056
    uint96 constant EX_PURCHASE_STAMP_01 = 4900570000000000000;
    // 4900570000000000000
    // 4900560000000000000

    address public owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address public publisher =
        address(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);

    address public buyer = address(0xa0Ee7A142d267C1f36714E4a8F75612F20a79720);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(publisher, 100 ether);

        publishCContentTokenBatch = new PublishCContentTokenBatch();
        publishCVariantBatch = new PublishCVariantBatch();
        publishSContentTokenBatch = new PublishSContentTokenBatch();
        publishSVariantBatch = new PublishSVariantBatch();
        wavSaleBatch = new WavSaleBatch();
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

        bytes4[] memory _wavSaleBatchSelectors = new bytes4[](2);
        _wavSaleBatchSelectors[0] = WavSaleBatch.wavSaleBatch.selector;
        _wavSaleBatchSelectors[1] = WavSaleBatch.wavAccessBatch.selector;

        _cut[6] = LibDiamond.FacetCut({
            facetAddress: address(wavSaleBatch),
            action: LibDiamond.FacetCutAction.Add,
            functionSelectors: _wavSaleBatchSelectors
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

    // forge test --match-test testWavSaleCContentTokenBatchHappyPath -vvvv

    function testWavSaleCContentTokenBatchHappyPath() public {
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

        /*bytes memory _payload = abi.encodeWithSelector(
            WavAccess(address(wavDiamond)).returnOwnership2.selector,
            buyer
        );

        (bool ok, bytes memory ret) = address(wavDiamond).call(_payload);

        console.log("low-level ok:", ok);
        console.log("returndata length:", ret.length);
        if (ret.length > 0) console.logBytes(ret);

        if (!ok) {
            if (ret.length > 0) {
                console.logBytes(ret);
            } else {
                console.log(
                    "no returndata (empty) - likely OOG or low-level revert without reason"
                );
            }
        }
        (bytes32[] memory _hashIds, uint16[] memory _numTokens) = abi.decode(
            ret,
            (bytes32[], uint16[])
        );*/

        //bytes32[] memory _hashIds = new bytes32[](2);
        //uint16[] memory _numTokens = new uint16[](2);

        /*(_hashIds, _numTokens) = WavAccess(address(wavDiamond))
            .returnOwnership2(buyer);*/

        /* CreatorTokenStorage.CreatorToken[] memory _ownedContent = WavAccess(
            address(wavDiamond)
        ).returnOwnership(buyer);*/
    }

    function testWavSaleCVariantBatchHappyPath() public {
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
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

    function testWavSaleCContentTokenVariantBatchHappyPath() public {
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
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

    function testWavSaleSContentTokenBatchHappyPath() public {
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
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

    // **** LET'S START HERE: ***********************

    function testWavSaleSVariantBatchHappyPath() public {
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

            vm.deal(buyer, 5 ether);
            vm.prank(owner);
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

    function testWavSaleSContentTokenVariantBatchHappyPath() public {
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
            priceUsdVal: uint32(EX_CPRICE_USD_01),
            supplyVal: uint112(EX_CSUPPLY_01),
            releaseVal: uint96(EX_CRELEASE_01)
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
            vm.warp(EX_PURCHASE_STAMP_01);
            WavSaleBatch(address(wavDiamond)).wavSaleBatch{value: _totalWei}(
                buyer,
                _wavSaleToken
            );
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

    // address: publisher
    // contentId: 0
    // variantIndex: 0
    // == 0x5492cbaff8791db03d5ad81c76ff54e38c20485579d006b31018cd9e550924df

    // address: publisher
    // contentId: 1
    // variantIndex: 0
    // == 0xbe88736984a371e37661d4e74c3ce8b7414b2f8d482b454f172b05c3454a4261

    // address: publisher
    // contentId: 1
    // variantIndex: 1
    // == 0x47c2c7783617def0008d06b6894cbc8a754d59b3f04c541f2188ce00337438ec

    // address: publisher
    // contentId: 2
    // variantIndex: 0
    // == 0x5dc59cca6c18406baff0694162d076e6c23fec106f47a3ef9617fccb7a880fa5

    // address: publisher
    // contentId: 2
    // variantIndex: 1
    // == 0xfc6417e146843f46524fbbcfaeb879915e16d7cd369c1d59f1b2ef9ef9931fc5

    // address: publisher
    // contentId: 3
    // variantIndex: 1
    // == 0x2884060828b337f14f2b4eaf8024f4072cda7800bba9fc2c9de91b2e9d5f85bb

    // address: publisher
    // contentId: 4
    // variantIndex: 1
    // == 0x3e623f0a6efb6fb58e953efe1eb813564f354a7b33454263467c63560421e4a6

    /*
    if (ok && ret.length > 4) {
            bytes memory sliced = new bytes(ret.length - 4);
            for (uint256 i = 4; i < ret.length; ++i) sliced[i - 4] = ret[i];
            try this._tryDecodeBytes32Uint256(sliced) returns (
                bytes32[] memory a,
                uint256[] memory b
            ) {
                console.log(
                    "Decode after skipping 4 bytes succeed. count:",
                    a.length
                );
                for (uint256 i = 0; i < a.length; ++i) {
                    console.logBytes32(a[i]);
                    console.logUint(b[i]);
                }
            } catch {
                console.log("Decode after skipping 4 bytes failed");
            }
        }


    */
}
