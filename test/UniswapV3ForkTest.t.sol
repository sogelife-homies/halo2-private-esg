// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "../contracts/interfaces/IERC20.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "solmate/utils/SafeTransferLib.sol";

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

contract UniswapV3ForkTest is Test, IUniswapV3MintCallback {
    using SafeTransferLib for IERC20;

    uint256 public FORK_AT_BLOCK = 18_149_980;
    address WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address USDC_ETH_005 = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;

    function mintMainnetWETH(address token, uint256 amount, address to) public {}

    function setUp() public {
        string memory RPC_URL = vm.envString("RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, FORK_AT_BLOCK);
        vm.selectFork(forkId);

        assertEq(block.number, FORK_AT_BLOCK);
        assertEq(
            vm.load(USDC_ETH_005, bytes32(uint256(0x1))),
            0x000000000000000000000000000000000000786c81dddd3294ff7bab5448d612
        );
    }

    function testForkedUniv3LPing() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);

        deal(USDC, address(this), 100 ether);
        assertEq(IERC20(USDC).balanceOf(address(this)), 100 ether);

        IUniswapV3Pool pool = IUniswapV3Pool(USDC_ETH_005);

        (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) = pool.slot0();
        console2.log(uint256(sqrtPriceX96));

        uint24 tickLower = tick - 100;
        uint24 tickUpper = tick + 100;

        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, 1600_000000, 1_000000000000000000
        );
        console2.log(uint256(liquidity));

        (uint256 a0, uint256 a1) =
            LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);
        console2.log(a0);
        console2.log(a1);

        (uint256 a0_, uint256 a1_) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        console2.log(a0_);
        console2.log(a1_);
    }

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata data) external override {
        require(msg.sender == address(USDC_ETH_005));
        if (amount0 > 0) IERC20(USDC).safeTransfer(msg.sender, amount0);
        if (amount1 > 0) IERC20(WETH).safeTransfer(msg.sender, amount1);
    }
}
