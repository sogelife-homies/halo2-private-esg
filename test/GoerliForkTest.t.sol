// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "./yul/YulDeployerTest.t.sol";
import "../contracts/SnarkedVault.sol";
import "../contracts/interfaces/IAxiomV1Query.sol";
import "./mocks/AxiomV1QueryMock.sol";
import "./mocks/MockERC20.sol";

// | Name                 | Type                                     | Slot | Offset | Bytes   | Contract                                  |
// |----------------------|------------------------------------------|------|--------|---------|-------------------------------------------|
// | slot0                | struct UniswapV3Pool.Slot0               | 0    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | feeGrowthGlobal0X128 | uint256                                  | 1    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | feeGrowthGlobal1X128 | uint256                                  | 2    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | protocolFees         | struct UniswapV3Pool.ProtocolFees        | 3    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | liquidity            | uint128                                  | 4    | 0      | 16      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | ticks                | mapping(int24 => struct Tick.Info)       | 5    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | tickBitmap           | mapping(int16 => uint256)                | 6    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | positions            | mapping(bytes32 => struct Position.Info) | 7    | 0      | 32      | contracts/UniswapV3Pool.sol:UniswapV3Pool |
// | observations         | struct Oracle.Observation[65535]         | 8    | 0      | 2097120 | contracts/UniswapV3Pool.sol:UniswapV3Pool |

contract GoerliForkTest is YulDeployerTest, IUniswapV3MintCallback {
    using SafeERC20 for IERC20;
    // https://www.geckoterminal.com/goerli-testnet/pools/0x4d1892f15b03db24b55e73f9801826a56d6f0755

    uint256 constant FORK_AT_BLOCK = 9852780;
    address constant WETH = 0xF81631aEdB2C5324c6dea012Ac3eb181F1179e6C;
    address constant USDC = 0x4eff99da09F7ea5aCb8754c3731012eC957591FB;
    address constant USDC_WETH_005 = 0x297FFb1BbAc2F906A7c8f10808E2E48825CF5b7f;
    IUniswapV3Pool pool = IUniswapV3Pool(USDC_WETH_005);
    int24 tickSpacing;

    function setUp() public {
        string memory RPC_URL = vm.envString("GOERLI_RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, FORK_AT_BLOCK);
        vm.selectFork(forkId);
        assertEq(block.number, FORK_AT_BLOCK);
        tickSpacing = pool.tickSpacing();
    }

    function _floor(int24 tick) internal view returns (int24) {
        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function testDummyStrat() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);
        deal(USDC, address(this), 100 ether);
        assertEq(IERC20(USDC).balanceOf(address(this)), 100 ether);

        address verifierAddress = deployVerifier();
        SnarkedVault dv = new SnarkedVault();
        AxiomV1QueryMock axiomMock = new AxiomV1QueryMock();
        dv.initialize(
            SnarkedVaultParams({
                pool: USDC_WETH_005,
                stratVerfifierAddress: verifierAddress,
                axiomV1QueryAddress: address(axiomMock),
                name: "ZK-MM LPs",
                symbol: "ZMLP",
                maxTotalSupply: type(uint256).max
            })
        );

        IERC20(USDC).approve(address(dv), 1 ether);
        IERC20(WETH).approve(address(dv), 1 ether);

        assert(IERC20(USDC).allowance(address(this), address(dv)) == 1 ether);
        assert(IERC20(WETH).allowance(address(this), address(dv)) == 1 ether);

        (uint256 shares,,) = dv.deposit(1 ether, 1 ether, 0.9 ether, 0.9 ether, address(this));
        assert(IERC20(USDC).balanceOf(address(this)) == 99 ether);
        assert(IERC20(WETH).balanceOf(address(this)) == 99 ether);

        dv.setAxiomV1QueryAddress(address(axiomMock));
        bytes memory proof = loadCallData("evm/call_data.hex");

        uint256 lowerBound = (uint256(BytesLib.toBytes32(proof, 0)));
        uint256 upperBound = (uint256(BytesLib.toBytes32(proof, 32)));
        console2.log(uint256(lowerBound));
        console2.log(uint256(upperBound));

        bytes memory axiomResponse = loadCallData("evm/call_axiom_proof.hex");

        SnarkedVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (SnarkedVault.ResponseStruct));
        //console2.log(decoded.storageResponses[0].value);

        dv.runStrat(proof, decoded);

        (uint256 withdrawed0, uint256 withdrawed1) = dv.withdraw(shares / 2, 0.49 ether, 0.49 ether, address(this));
        assert(IERC20(USDC).balanceOf(address(this)) == 99 ether + withdrawed0);
        assert(IERC20(WETH).balanceOf(address(this)) == 99 ether + withdrawed1);
    }

    function testDummyStratNewPool() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);

        MockERC20 USDC = new MockERC20();
        address usdcAddress = address(USDC);

        deal(usdcAddress, address(this), 100 ether);
        assertEq(USDC.balanceOf(address(this)), 100 ether);

        // IUniswapV3Factory factory = IUniswapV3Factory(V3_FACTORY);
        // address pool = factory.createPool(usdcAddress, WETH, 500);

        // (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        // // console2.log(uint256(sqrtPriceX96));

        // int24 tickLower = _floor(tick);
        // int24 tickUpper = tickLower + tickSpacing;

        // uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        // uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        // uint128 liquidity =
        //     LiquidityAmounts.getLiquidityForAmounts(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, 0, 1_000000000000000000);
        // console2.log(uint256(liquidity));

        // (uint256 a0, uint256 a1) =
        //     LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);
        // console2.log(a0);
        // console2.log(a1);

        // (uint256 a0_, uint256 a1_) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        // console2.log(a0_);
        // console2.log(a1_);

        // assert(IERC20(USDC).balanceOf(address(this)) == 100 ether - a0_);
        // assert(IERC20(WETH).balanceOf(address(this)) == 100 ether - a1_);

        // (uint256 w0_, uint256 w1_) = pool.burn(tickLower, tickUpper, liquidity);
        // console2.log(w0_);
        // console2.log(w1_);
    }

    function testForkedUniv3LPing() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);

        deal(USDC, address(this), 100 ether);
        assertEq(IERC20(USDC).balanceOf(address(this)), 100 ether);

        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        // console2.log(uint256(sqrtPriceX96));

        int24 tickLower = _floor(tick);
        int24 tickUpper = tickLower + tickSpacing;

        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomProof = loadCallData("evm/call_axiom_proof.hex");
        SnarkedVault.ResponseStruct memory decoded = abi.decode(axiomProof, (SnarkedVault.ResponseStruct));

        uint160 sqrtRatioAX96 = uint160(decoded.storageResponses[31].value & type(uint160).max);
        uint160 sqrtRatioBX96 = uint160(decoded.storageResponses[32].value & type(uint160).max);
        // console2.log(uint256(sqrtRatioAX96));
        // console2.log(uint256(sqrtRatioBX96));

        // uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        // uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, 1600_000000, 1_000000000000000000
        );
        // console2.log(uint256(liquidity));

        (uint256 a0, uint256 a1) =
            LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);
        // console2.log(a0);
        // console2.log(a1);

        (uint256 a0_, uint256 a1_) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        // console2.log(a0_);
        // console2.log(a1_);

        assert(IERC20(USDC).balanceOf(address(this)) == 100 ether - a0_);
        assert(IERC20(WETH).balanceOf(address(this)) == 100 ether - a1_);

        (uint256 w0_, uint256 w1_) = pool.burn(tickLower, tickUpper, liquidity);
        // console2.log(w0_);
        // console2.log(w1_);
    }

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata) external override {
        require(msg.sender == address(USDC_WETH_005));
        if (amount0 > 0) IERC20(USDC).safeTransfer(msg.sender, amount0);
        if (amount1 > 0) IERC20(WETH).safeTransfer(msg.sender, amount1);
    }
}
