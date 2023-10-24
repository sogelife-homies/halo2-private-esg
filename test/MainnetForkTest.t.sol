// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "./yul/YulDeployerTest.t.sol";
import "../contracts/DummyVault.sol";
import "../contracts/libraries/BytesLib.sol";
import "../contracts/interfaces/IAxiomV1Query.sol";
import "./mocks/AxiomV1QueryMock.sol";

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

contract MainnetForkTest is YulDeployerTest, IUniswapV3MintCallback {
    using SafeERC20 for IERC20;

    uint256 constant FORK_AT_BLOCK = 18_149_980;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant USDC_WETH_005 = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640;
    IUniswapV3Pool pool = IUniswapV3Pool(USDC_WETH_005);
    int24 tickSpacing;
    //constructor() ForkTest(FORK_AT_BLOCK, USDC, WETH, USDC_WETH_005) {}

    function setUp() public {
        string memory RPC_URL = vm.envString("RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, FORK_AT_BLOCK);
        vm.selectFork(forkId);
        assertEq(block.number, FORK_AT_BLOCK);
        assertEq(
            vm.load(USDC_WETH_005, bytes32(uint256(0x1))),
            0x000000000000000000000000000000000000786c81dddd3294ff7bab5448d612
        );
        tickSpacing = pool.tickSpacing();
    }
    /// @dev Rounds tick down towards negative infinity so that it's a multiple
    /// of `tickSpacing`.

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
        DummyVault dv = new DummyVault();
        AxiomV1QueryMock axiomMock = new AxiomV1QueryMock();
        dv.initialize(DummyVaultParams({
            pool: USDC_WETH_005,
            stratVerfifierAddress: verifierAddress,
            axiomV1QueryAddress: address(axiomMock),
            name: "ZK-MM LPs",
            symbol: "ZMLP",
            maxTotalSupply: type(uint256).max
        }));

        IERC20(USDC).approve(address(dv), 1 ether);
        IERC20(WETH).approve(address(dv), 1 ether);

        assert(IERC20(USDC).allowance(address(this), address(dv)) == 1 ether);
        assert(IERC20(WETH).allowance(address(this), address(dv)) == 1 ether);

        dv.deposit(1 ether, 1 ether, 0.9 ether, 0.9 ether, address(this));
        assert(IERC20(USDC).balanceOf(address(this)) == 99 ether);
        assert(IERC20(WETH).balanceOf(address(this)) == 99 ether);

        dv.setAxiomV1QueryAddress(address(axiomMock));
        bytes memory proof = loadCallData("evm/call_data.hex");

        uint256 lowerBound = (uint256(BytesLib.toBytes32(proof, 0)));
        uint256 upperBound = (uint256(BytesLib.toBytes32(proof, 32)));
        console2.log(uint256(lowerBound));
        console2.log(uint256(upperBound));

        bytes memory axiomResponse = loadCallData("evm/call_axiom_proof.hex");
        
        DummyVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (DummyVault.ResponseStruct));
        //console2.log(decoded.storageResponses[0].value);

        dv.runStrat(proof, decoded);
    }

    function testForkedUniv3LPing() public {
        deal(WETH, address(this), 100 ether);
        assertEq(IERC20(WETH).balanceOf(address(this)), 100 ether);

        deal(USDC, address(this), 100 ether);
        assertEq(IERC20(USDC).balanceOf(address(this)), 100 ether);

        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        // console2.log(uint256(sqrtPriceX96));
        // int24 tickLower = _floor(tick);
        // int24 tickUpper = tickLower + tickSpacing;

        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomProof = loadCallData("evm/call_axiom_proof.hex");
        DummyVault.ResponseStruct memory decoded = abi.decode(axiomProof, (DummyVault.ResponseStruct));

        uint160 sqrtRatioAX96 = uint160(decoded.storageResponses[31].value & type(uint160).max);
        uint160 sqrtRatioBX96 = uint160(decoded.storageResponses[32].value & type(uint160).max);
        // console2.log(uint256(sqrtRatioAX96));
        // console2.log(uint256(sqrtRatioBX96));

        // uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        // uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, 1600_000000, 1_000000000000000000
        );

        int24 tickLower = TickMath.getTickAtSqrtRatio(sqrtRatioAX96);
        tickLower -= tickLower % 10;
        int24 tickUpper = TickMath.getTickAtSqrtRatio(sqrtRatioBX96);
        tickUpper -= tickUpper % 10;
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
