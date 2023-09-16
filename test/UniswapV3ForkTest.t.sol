// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

contract UniswapV3ForkTest is Test {
    function setUp() public {
        string memory RPC_URL = vm.envString("RPC_URL");
        uint256 forkId = vm.createFork(RPC_URL, 1_337_000);
        vm.selectFork(forkId);

        assertEq(block.number, 1_337_000);
    }

    function testUniv3LPing() public {}
}
