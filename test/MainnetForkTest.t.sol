// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/SafeERC20.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "./yul/YulDeployerTest.t.sol";
//import "./ForkTest.t.sol";
import "../contracts/DummyVault.sol";
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

    // function a(address verifierAddress, bytes memory proof) public {
    //     verifierAddress.call(proof);
    // }

    function testDummyStrat() public {
        //tickSpacing = pool.tickSpacing();

        address verifierAddress = deployVerifier();
        DummyVault dv = new DummyVault(USDC_WETH_005, verifierAddress);
        AxiomV1QueryMock axiomMock = new AxiomV1QueryMock();

        dv.setAxiomV1QueryAddress(address(axiomMock));
        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomResponse =
            hex"00000000000000000000000000000000000000000000000000000000000000206000f5edcb28fd8a47a86fd708ce7ae05e0ccb524c659297e633abe8bfe58736a58b3021fdc4f7c6b45af00f1c9db3b9f51a061d4650fea4e260d90383fbed7a1b3633944a7d2eb24a2399be2a8179ad73cabd0f65c99c74763d492056164f7400000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b144fe76620a5a743c01709bf80a005ca314cff6c5f50939b5b7845d3ea9a94403f00000000000000000000000000000000000000000000000000000000000000003a087e59482812269efc4792327baa920bd01fd14468337ca3e2fd9b1397c350ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa9072200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000bd24cf192ee57af9c911cbba4664a6097746ac0603a5e237989266f3deffa51350cd42c33f06d13cd5fe3c57613bf2f330da95d6801bb1142a63dfd1a364d5b7000000000000000000000000000000000000000000000000000000000000000079e9499f0de3297006a300d48a6f1018f32f7f488a3f47eb6115db96798e090bad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa907220000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000101cc73a7fbeb427b026e8252ec723f8a900000000000000000000000000000000000000000000000000000000000000003f1d422a05bea118012fd9e48879fcca621beb11d455b72dc3b5aa2be2b6b53ead3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d";

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

        int24 tickLower = _floor(tick);
        int24 tickUpper = tickLower + tickSpacing;

        uint160 sqrtRatioAX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 sqrtRatioBX96 = TickMath.getSqrtRatioAtTick(tickUpper);

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
