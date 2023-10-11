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
//import "./ForkTest.t.sol";
import "../contracts/DummyVault.sol";
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

    uint256 constant FORK_AT_BLOCK = 9746819;
    address constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address constant V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    int24 tickSpacing;

    function setUp() public {
        string memory RPC_URL = vm.envString("GOERLI_RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, FORK_AT_BLOCK);
        vm.selectFork(forkId);
        assertEq(block.number, FORK_AT_BLOCK);
    }

    function _floor(int24 tick) internal view returns (int24) {
        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function testDummyStratNewPool() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);

        MockERC20 USDC = new MockERC20();
        address usdcAddress = address(USDC);

        deal(usdcAddress, address(this), 100 ether);
        assertEq(USDC.balanceOf(address(this)), 100 ether);

        IUniswapV3Factory factory = IUniswapV3Factory(V3_FACTORY);
        address pool = factory.createPool(usdcAddress, WETH, 500);

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

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata) external override {
        // require(msg.sender == address(USDC_WETH_005));
        // if (amount0 > 0) IERC20(USDC).safeTransfer(msg.sender, amount0);
        // if (amount1 > 0) IERC20(WETH).safeTransfer(msg.sender, amount1);
    }
}
