// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "openzeppelin/access/Ownable.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/math/SafeMath.sol";
import "v3-periphery/libraries/PositionKey.sol";
import "./interfaces/IAxiomV1Query.sol";
import "./libraries/BytesLib.sol";

struct DummyVaultParams {
    address pool;
    int24 baseThreshold;
    int24 limitThreshold;
    uint24 fullRangeWeight;
    address stratVerfifierAddress;
}

contract DummyVault is Ownable, IUniswapV3MintCallback {
    using SafeMath for uint256;

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
    IUniswapV3Pool public poolAddress;

    uint24 public fullRangeWeight;
    int24 public baseThreshold;
    int24 public limitThreshold;
    int24 public tickSpacing;
    int24 public fullLower;
    int24 public fullUpper;
    int24 public baseLower;
    int24 public baseUpper;
    int24 public limitLower;
    int24 public limitUpper;

    IERC20 token0;
    IERC20 token1;

    constructor() Ownable() {
    }

    function initialize(DummyVaultParams memory _params) public {
        poolAddress = IUniswapV3Pool(_params.pool);

        token0 = IERC20(poolAddress.token0());
        token1 = IERC20(poolAddress.token1());

        int24 _tickSpacing = poolAddress.tickSpacing();
        tickSpacing = _tickSpacing;

        baseThreshold = _params.baseThreshold;
        limitThreshold = _params.limitThreshold;
        fullRangeWeight = _params.fullRangeWeight;

        fullLower = (TickMath.MIN_TICK / _tickSpacing) * _tickSpacing;
        fullUpper = (TickMath.MAX_TICK / _tickSpacing) * _tickSpacing;

        stratVerfifierAddress = _params.stratVerfifierAddress;

        _checkThreshold(_params.baseThreshold, _tickSpacing);
        _checkThreshold(_params.limitThreshold, _tickSpacing);
        require(_params.fullRangeWeight <= 1e6, "fullRangeWeight must be <= 1e6");
        require(_params.stratVerfifierAddress != address(0), "No verifier");
    }

    function _checkThreshold(int24 threshold, int24 _tickSpacing) internal pure {
        require(threshold > 0, "threshold must be > 0");
        require(threshold <= TickMath.MAX_TICK, "threshold too high");
        require(threshold % _tickSpacing == 0, "threshold must be multiple of tickSpacing");
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

    function _floor(int24 tick) internal view returns (int24) {
        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--;
        return compressed * tickSpacing;
    }

    function _position(
        int24 tickLower,
        int24 tickUpper
    ) internal view returns (uint128, uint256, uint256, uint128, uint128) {
        bytes32 positionKey = PositionKey.compute(address(this), tickLower, tickUpper);
        return poolAddress.positions(positionKey);
    }

    function _burnAndCollect(
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity
    )
        internal
        returns (uint256 burned0, uint256 burned1, uint256 feesToVault0, uint256 feesToVault1)
    {
        if (liquidity > 0) {
            (burned0, burned1) = poolAddress.burn(tickLower, tickUpper, liquidity);
        }

        // Collect all owed tokens including earned fees
        (uint256 collect0, uint256 collect1) = poolAddress.collect(
            address(this),
            tickLower,
            tickUpper,
            type(uint128).max,
            type(uint128).max
        );

        feesToVault0 = collect0.sub(burned0);
        feesToVault1 = collect1.sub(burned1);
    }

    function _mintLiquidity(int24 tickLower, int24 tickUpper, uint128 liquidity) internal {
        if (liquidity > 0) {
            poolAddress.mint(address(this), tickLower, tickUpper, liquidity, "");
        }
    }

     function _liquidityForAmounts(
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0,
        uint256 amount1
    ) internal view returns (uint128) {
        (uint160 sqrtRatioX96, , , , , , ) = poolAddress.slot0();
        return
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtRatioX96,
                TickMath.getSqrtRatioAtTick(tickLower),
                TickMath.getSqrtRatioAtTick(tickUpper),
                amount0,
                amount1
            );
    }

    /// @dev Casts uint256 to uint128 with overflow check.
    function _toUint128(uint256 x) internal pure returns (uint128) {
        assert(x <= type(uint128).max);
        return uint128(x);
    }

    function getBalance0() public view returns (uint256) {
        return
            token0.balanceOf(address(this));
    }

    /**
     * @notice Balance of token1 in vault not used in any position.
     */
    function getBalance1() public view returns (uint256) {
        return
            token1.balanceOf(address(this));
    }

    // TODO public witness in included both axiomResponse and stratProof (*)

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

        // Rebelance

        int24 _fullLower = fullLower;
        int24 _fullUpper = fullUpper;
        {
            (uint128 fullLiquidity, , , , ) = _position(_fullLower, _fullUpper);
            (uint128 baseLiquidity, , , , ) = _position(baseLower, baseUpper);
            (uint128 limitLiquidity, , , , ) = _position(limitLower, limitUpper);
            _burnAndCollect(_fullLower, _fullUpper, fullLiquidity);
            _burnAndCollect(baseLower, baseUpper, baseLiquidity);
            _burnAndCollect(limitLower, limitUpper, limitLiquidity);
        }

        // Calculate new ranges
        (, int24 tick, , , , , ) = poolAddress.slot0();
        int24 tickFloor = _floor(tick);
        int24 tickCeil = tickFloor + tickSpacing;

        int24 _baseLower = tickFloor - baseThreshold;
        int24 _baseUpper = tickCeil + baseThreshold;
        int24 _bidLower = tickFloor - limitThreshold;
        int24 _bidUpper = tickFloor;
        int24 _askLower = tickCeil;
        int24 _askUpper = tickCeil + limitThreshold;

        // Emit snapshot to record balances and supply
        uint256 balance0 = getBalance0();
        uint256 balance1 = getBalance1();

        // Place full range order on Uniswap
        {
            uint128 maxFullLiquidity = _liquidityForAmounts(
                _fullLower,
                _fullUpper,
                balance0,
                balance1
            );
            uint128 fullLiquidity = _toUint128(
                uint256(maxFullLiquidity).mul(fullRangeWeight).div(1e6)
            );
            _mintLiquidity(_fullLower, _fullUpper, fullLiquidity);
        }

        // Place base order on Uniswap
        balance0 = getBalance0();
        balance1 = getBalance1();
        {
            uint128 baseLiquidity = _liquidityForAmounts(
                _baseLower,
                _baseUpper,
                balance0,
                balance1
            );
            _mintLiquidity(_baseLower, _baseUpper, baseLiquidity);
            (baseLower, baseUpper) = (_baseLower, _baseUpper);
        }

        // Place bid or ask order on Uniswap depending on which token is left
        balance0 = getBalance0();
        balance1 = getBalance1();
        uint128 bidLiquidity = _liquidityForAmounts(_bidLower, _bidUpper, balance0, balance1);
        uint128 askLiquidity = _liquidityForAmounts(_askLower, _askUpper, balance0, balance1);
        if (bidLiquidity > askLiquidity) {
            _mintLiquidity(_bidLower, _bidUpper, bidLiquidity);
            (limitLower, limitUpper) = (_bidLower, _bidUpper);
        } else {
            _mintLiquidity(_askLower, _askUpper, askLiquidity);
            (limitLower, limitUpper) = (_askLower, _askUpper);
        }
    }

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata) external override {
        // require(msg.sender == address(USDC_ETH_005));
        // if (amount0 > 0) IERC20(USDC).safeTransfer(msg.sender, amount0);
        // if (amount1 > 0) IERC20(WETH).safeTransfer(msg.sender, amount1);
    }
}
