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
import "../contracts/DummyVault.sol";
import "../contracts/interfaces/IAxiomV1Query.sol";
import "./mocks/AxiomV1QueryMock.sol";

abstract contract ForkTest is YulDeployerTest, IUniswapV3MintCallback {
    uint256 public forkAtBlock;
    address public token0Address;
    address public token1Address;
    address public poolAddress;
    IUniswapV3Pool public pool;
    int24 public tickSpacing;

    function setUpFork(uint256 _forkAtBlock, address _token0Address, address _token1Address, address _poolAddress)
        public
    {
        forkAtBlock = _forkAtBlock;
        token0Address = _token0Address;
        token1Address = _token1Address;
        poolAddress = _poolAddress;
        pool = IUniswapV3Pool(pool);
        string memory RPC_URL = vm.envString("RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, forkAtBlock);
        vm.selectFork(forkId);
        assertEq(block.number, forkAtBlock);

        tickSpacing = pool.tickSpacing();
    }
}
