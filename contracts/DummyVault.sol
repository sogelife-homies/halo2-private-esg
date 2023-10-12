// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

import "v3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol";
import "v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol";
import "v3-core/contracts/interfaces/IUniswapV3Pool.sol";

import "v3-periphery/libraries/LiquidityAmounts.sol";
import "v3-core/contracts/libraries/TickMath.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin/token/ERC20/IERC20.sol";
import "v3-periphery/libraries/PositionKey.sol";
import "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import "openzeppelin-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "openzeppelin-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import "./interfaces/IAxiomV1Query.sol";
import "./libraries/BytesLib.sol";

struct DummyVaultParams {
    address pool;
    address axiomV1QueryAddress;
    address stratVerfifierAddress;
    uint256 maxTotalSupply;
    string name;
    string symbol;
}

contract DummyVault is Initializable, OwnableUpgradeable, IUniswapV3MintCallback, ERC20Upgradeable, ReentrancyGuardUpgradeable {
    using SafeERC20 for IERC20;

    struct ResponseStruct {
        bytes32 keccakQueryResponse;
    }

    uint256 public constant MINIMUM_LIQUIDITY = 1e3;

    event RebalanceData(uint32 blockNumber, address addr, uint256 slot, uint256 value);
    event Deposit(address indexed sender, address indexed to, uint256 shares, uint256 amount0, uint256 amount1);

    // storage poof verifier
    address public axiomV1QueryAddress; // Goerli address

    // halo-2 strat verifier
    address public stratVerfifierAddress;
    // pool
    IUniswapV3Pool public poolAddress;

    int24 public tickSpacing;
    int24 public baseLower;
    int24 public baseUpper;
    int24 public limitLower;
    int24 public limitUpper;
    uint256 public maxTotalSupply;

    IERC20 token0;
    IERC20 token1;

    function initialize(DummyVaultParams memory _params) public initializer {
        __ERC20_init(_params.name, _params.symbol);
        __ReentrancyGuard_init();
        __Ownable_init(_msgSender());

        poolAddress = IUniswapV3Pool(_params.pool);

        token0 = IERC20(poolAddress.token0());
        token1 = IERC20(poolAddress.token1());

        int24 _tickSpacing = poolAddress.tickSpacing();
        tickSpacing = _tickSpacing;

        stratVerfifierAddress = _params.stratVerfifierAddress;
        axiomV1QueryAddress = _params.axiomV1QueryAddress;

        maxTotalSupply = _params.maxTotalSupply;

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

        bool valid = axiomV1Query.verifiedKeccakResults(
            axiomResponse.keccakQueryResponse
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

        feesToVault0 = collect0 - burned0;
        feesToVault1 = collect1 - burned1;
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

    function getBalance0() public view returns (uint256) {
        return
            token0.balanceOf(address(this));
    }

    function getBalance1() public view returns (uint256) {
        return
            token1.balanceOf(address(this));
    }

    function _poke(int24 tickLower, int24 tickUpper) internal {
        (uint128 liquidity,,,,) = _position(tickLower, tickUpper);
        if (liquidity > 0) {
            poolAddress.burn(tickLower, tickUpper, 0);
        }
    }

    function _amountsForLiquidity(int24 tickLower, int24 tickUpper, uint128 liquidity)
        internal
        view
        returns (uint256, uint256)
    {
        (uint160 sqrtRatioX96,,,,,,) = poolAddress.slot0();
        return LiquidityAmounts.getAmountsForLiquidity(
            sqrtRatioX96, TickMath.getSqrtRatioAtTick(tickLower), TickMath.getSqrtRatioAtTick(tickUpper), liquidity
        );
    }
    
    function getPositionAmounts(int24 tickLower, int24 tickUpper)
        public
        view
        returns (uint256 amount0, uint256 amount1)
    {
        (uint128 liquidity,,, uint128 tokensOwed0, uint128 tokensOwed1) = _position(tickLower, tickUpper);
        (amount0, amount1) = _amountsForLiquidity(tickLower, tickUpper, liquidity);

        // Subtract protocol and manager fees
        amount0 = (amount0 + uint256(tokensOwed0)) / 1e6;
        amount1 = (amount1 + uint256(tokensOwed1)) / 1e6;
    }

    function getTotalAmounts() public view returns (uint256 total0, uint256 total1) {
        (uint256 baseAmount0, uint256 baseAmount1) = getPositionAmounts(baseLower, baseUpper);
        (uint256 limitAmount0, uint256 limitAmount1) = getPositionAmounts(limitLower, limitUpper);
        total0 = getBalance0() + baseAmount0 + limitAmount0;
        total1 = getBalance1() + baseAmount1 + limitAmount1;
    }

    function _calcSharesAndAmounts(uint256 amount0Desired, uint256 amount1Desired)
        internal
        view
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        uint256 totalSupply = totalSupply();
        (uint256 total0, uint256 total1) = getTotalAmounts();

        // If total supply > 0, vault can't be empty
        assert(totalSupply == 0 || total0 > 0 || total1 > 0);

        if (totalSupply == 0) {
            // For first deposit, just use the amounts desired
            amount0 = amount0Desired;
            amount1 = amount1Desired;
            shares = (amount0 > amount1 ? amount0 : amount1) - MINIMUM_LIQUIDITY;
        } else if (total0 == 0) {
            amount1 = amount1Desired;
            shares = amount1 * totalSupply / total1;
        } else if (total1 == 0) {
            amount0 = amount0Desired;
            shares = amount0 * totalSupply / total0;
        } else {
            uint256 cross0 = amount0Desired * total1;
            uint256 cross1 = amount1Desired * total0;
            uint256 cross = cross0 > cross1 ? cross1 : cross0;
            require(cross > 0, "cross");

            // Round up amounts
            amount0 = (cross - 1) / (total1 + 1);
            amount1 = (cross - 1) / (total0 + 1);
            shares = (cross * totalSupply) / total0 / total1;
        }
    }

    // TODO public witness in included both axiomResponse and stratProof (*)

    function deposit(uint256 amount0Desired, uint256 amount1Desired, uint256 amount0Min, uint256 amount1Min, address to)
        external
        nonReentrant
        returns (uint256 shares, uint256 amount0, uint256 amount1)
    {
        require(amount0Desired > 0 || amount1Desired > 0, "amount0Desired or amount1Desired");
        require(to != address(0) && to != address(this), "to");

        // Poke positions so vault's current holdings are up-to-date
        _poke(baseLower, baseUpper);
        _poke(limitLower, limitUpper);

        // Calculate amounts proportional to vault's holdings
        (shares, amount0, amount1) = _calcSharesAndAmounts(amount0Desired, amount1Desired);
        require(shares > 0, "shares");
        require(amount0 >= amount0Min, "amount0Min");
        require(amount1 >= amount1Min, "amount1Min");

        // Permanently lock the first MINIMUM_LIQUIDITY tokens
        if (totalSupply() == 0) {
            _mint(owner(), MINIMUM_LIQUIDITY);
        }

        // Pull in tokens from sender
        if (amount0 > 0) token0.safeTransferFrom(msg.sender, address(this), amount0);
        if (amount1 > 0) token1.safeTransferFrom(msg.sender, address(this), amount1);

        // Mint shares to recipient
        _mint(to, shares);
        emit Deposit(msg.sender, to, shares, amount0, amount1);
        require(totalSupply() <= maxTotalSupply, "maxTotalSupply");
    }

    function _applyTickSpacing(int24 tick, int24 tickSpacing) internal pure returns (int24) {
        return tick + (tickSpacing - (tick % tickSpacing));
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

        // Rebelance

        int24 lowerBound = _applyTickSpacing(
            TickMath.getTickAtSqrtRatio(uint160(uint256(BytesLib.toBytes32(stratProof, 4096 / 2)))),
            tickSpacing
        );
        int24 upperBound = _applyTickSpacing(
            TickMath.getTickAtSqrtRatio(uint160(uint256(BytesLib.toBytes32(stratProof, 4096 / 2 + 32)))),
            tickSpacing
        );

        {
            (uint128 baseLiquidity, , , , ) = _position(baseLower, baseUpper);
            (uint128 limitLiquidity, , , , ) = _position(limitLower, limitUpper);
            _burnAndCollect(baseLower, baseUpper, baseLiquidity);
            _burnAndCollect(limitLower, limitUpper, limitLiquidity);
        }

        // Calculate new ranges
        (, int24 tick, , , , , ) = poolAddress.slot0();
        int24 tickFloor = _floor(tick);
        int24 tickCeil = tickFloor + tickSpacing;

        int24 _baseLower = lowerBound;
        int24 _baseUpper = upperBound;
        int24 _bidLower = lowerBound;
        int24 _bidUpper = tickFloor;
        int24 _askLower = tickCeil;
        int24 _askUpper = upperBound;

        int24 _bidRange;
        int24 _askRange;

        if (lowerBound < tickFloor) _bidRange = tickFloor - lowerBound;
        if (upperBound > tickCeil) _askRange = upperBound - tickCeil;

        // Place base order on Uniswap
        uint256 balance0 = getBalance0();
        uint256 balance1 = getBalance1();

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
            if (_bidRange > 0) {
                _mintLiquidity(_bidLower, _bidUpper, bidLiquidity);
            }
            (limitLower, limitUpper) = (_bidLower, _bidUpper);
        } else {
            if (_askRange > 0) {
                _mintLiquidity(_askLower, _askUpper, askLiquidity);
            }
            (limitLower, limitUpper) = (_askLower, _askUpper);
        }
    }

    function uniswapV3MintCallback(uint256 amount0, uint256 amount1, bytes calldata) external override {
        require(msg.sender == address(poolAddress));
        if (amount0 > 0) IERC20(token0).safeTransfer(msg.sender, amount0);
        if (amount1 > 0) IERC20(token1).safeTransfer(msg.sender, amount1);
    }
}
