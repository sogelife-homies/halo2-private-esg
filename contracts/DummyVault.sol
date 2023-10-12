// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/SafeERC20.sol";
import "./interfaces/IAxiomV1Query.sol";
import "./libraries/BytesLib.sol";

contract DummyVault is Ownable, IUniswapV3MintCallback {
    using SafeERC20 for IERC20;

    struct ResponseStruct {
        bytes32 keccakBlockResponse;
        bytes32 keccakAccountResponse;
        bytes32 keccakStorageResponse;
        IAxiomV1Query.BlockResponse[] blockResponses;
        IAxiomV1Query.AccountResponse[] accountResponses;
        IAxiomV1Query.StorageResponse[] storageResponses;
    }

    event RebalanceData(uint32 blockNumber, address addr, uint256 slot, uint256 value);

    // storage poof verifier
    address public axiomV1QueryAddress = 0x4Fb202140c5319106F15706b1A69E441c9536306; // Goerli address

    // halo-2 strat verifier
    address public stratVerfifierAddress;
    // pool
    address public poolAddress;
    address public token0;
    address public token1;
    IUniswapV3Pool public pool;

    constructor(address _poolAddress, address _stratVerfifierAddress) Ownable() {
        require(_stratVerfifierAddress != address(0), "No verifier");
        stratVerfifierAddress = _stratVerfifierAddress;
        poolAddress = _poolAddress;
        pool = IUniswapV3Pool(_poolAddress);
        token0 = pool.token0();
        token1 = pool.token1();
    }

    function setAxiomV1QueryAddress(address _axiomV1QueryAddress) external onlyOwner {
        axiomV1QueryAddress = _axiomV1QueryAddress;
    }

    function setStratVerfifierAddress(address _stratVerfifierAddress) external onlyOwner {
        stratVerfifierAddress = _stratVerfifierAddress;
    }

    function _validateStorageProof(ResponseStruct calldata axiomResponse) private view {
        IAxiomV1Query axiomV1Query = IAxiomV1Query(axiomV1QueryAddress);

        bool valid = axiomV1Query.areResponsesValid(
            axiomResponse.keccakBlockResponse,
            axiomResponse.keccakAccountResponse,
            axiomResponse.keccakStorageResponse,
            axiomResponse.blockResponses,
            axiomResponse.accountResponses,
            axiomResponse.storageResponses
        );
        if (!valid) {
            revert("StorageProofValidationError");
        }
    }

    function deposit(uint256 amount0Desired, uint256 amount1Desired) public {
        if (amount0Desired > 0) IERC20(token0).safeTransferFrom(msg.sender, address(this), amount0Desired);
        if (amount1Desired > 0) IERC20(token1).safeTransferFrom(msg.sender, address(this), amount1Desired);
    }

    function runStrat(bytes calldata stratProof, ResponseStruct calldata axiomResponse) public {
        // Extract instances from proof
        // The public instances are laid out in the proof calldata as follows:
        // First 4 * 3 * 32 = 384 bytes are reserved for proof verification data used with the pairing precompile
        // 384..384 + 32 * 2: blockHash (32 bytes) as two uint128 cast to uint256, because zk proof uses 254 bit field and cannot fit uint256 into a single element
        // 384 + 32 * 2..384 + 32 * 3: blockNumber as uint256
        // 384 + 32 * 3..384 + 32 * 4: address as uint256
        // Followed by SLOT_NUMBER pairs of (slot, value)s, where slot: bytes32, value: uint256 laid out as:
        // index..index + 32 * 2: `slot` (32 bytes) as two uint128 cast to uint256, same as blockHash
        // index + 32 * 2..index + 32 * 4: `value` (32 bytes) as two uint128 cast to uint256, same as blockHash
        // uint256 _blockHash = (uint256(bytes32(proof[384:384 + 32])) << 128) | uint128(bytes16(proof[384 + 48:384 + 64]));
        // uint256 _blockNumber = uint256(bytes32(proof[384 + 64:384 + 96]));
        // address account = address(bytes20(proof[384 + 108:384 + 128]));

        // uint256 _blockHash =
        //     (uint256(BytesLib.toBytes32(proof, 384)) << 128) | uint128(BytesLib.toBytes16(proof, 384 + 48));
        // uint256 _blockNumber = uint256(bytes32(proof[384 + 64:384 + 96]));
        // address account = address(bytes20(proof[384 + 108:384 + 128]));
        //revert("SnarkVerificationFailed");
        _validateStorageProof(axiomResponse);
        (bool success,) = stratVerfifierAddress.call(stratProof);
        if (!success) {
            revert("SnarkVerificationFailed");
        }

        uint160 sqrtRatioAX96 = uint160((uint256(BytesLib.toBytes32(stratProof, 4096 / 2))));
        uint160 sqrtRatioBX96 = uint160((uint256(BytesLib.toBytes32(stratProof, 4096 / 2 + 32))));

        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();

        uint128 liquidity = LiquidityAmounts.getLiquidityForAmounts(
            sqrtPriceX96,
            sqrtRatioAX96,
            sqrtRatioBX96,
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        );
        // console2.log(uint256(liquidity));

        (uint256 a0, uint256 a1) =
            LiquidityAmounts.getAmountsForLiquidity(sqrtPriceX96, sqrtRatioAX96, sqrtRatioBX96, liquidity);
        // console2.log(a0);
        // console2.log(a1);

        //(uint256 a0_, uint256 a1_) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        // console2.log(a0_);
        // console2.log(a1_);
    }

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata) external override {
        // require(msg.sender == address(USDC_ETH_005));
        // if (amount0 > 0) IERC20(USDC).safeTransfer(msg.sender, amount0);
        // if (amount1 > 0) IERC20(WETH).safeTransfer(msg.sender, amount1);
    }
}
