// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import "./yul/YulDeployerTest.t.sol";
import "../contracts/SnarkedKPIVault.sol";

contract SnarkedKPIVault is YulDeployerTest {
    function testDummyStrat() public {
        address verifierAddress = deployVerifier();
        SnarkedVault dv = new SnarkedVault();

        uint256 companyId = 123;
        uint256 kpiId = 1;
        uint256 value = 500;

        assertEq(kpiStore.getKPI(companyId, kpiId), 0);
        kpiStore.setKPI(companyId, kpiId, value);
        assertEq(kpiStore.getKPI(companyId, kpiId), value);

        // AxiomV1QueryMock axiomMock = new AxiomV1QueryMock();
        // dv.initialize(
        //     SnarkedVaultParams({
        //         pool: USDC_WETH_005,
        //         stratVerfifierAddress: verifierAddress,
        //         axiomV1QueryAddress: address(axiomMock),
        //         name: "ZK-MM LPs",
        //         symbol: "ZMLP",
        //         maxTotalSupply: type(uint256).max
        //     })
        // );

        // IERC20(USDC).approve(address(dv), 1 ether);
        // IERC20(WETH).approve(address(dv), 1 ether);

        // assert(IERC20(USDC).allowance(address(this), address(dv)) == 1 ether);
        // assert(IERC20(WETH).allowance(address(this), address(dv)) == 1 ether);

        // (uint256 shares,,) = dv.deposit(1 ether, 1 ether, 0.9 ether, 0.9 ether, address(this));
        // assert(IERC20(USDC).balanceOf(address(this)) == 99 ether);
        // assert(IERC20(WETH).balanceOf(address(this)) == 99 ether);

        // dv.setAxiomV1QueryAddress(address(axiomMock));
        // bytes memory proof = loadCallData("evm/call_data.hex");

        // uint256 lowerBound = (uint256(BytesLib.toBytes32(proof, 0)));
        // uint256 upperBound = (uint256(BytesLib.toBytes32(proof, 32)));
        // console2.log(uint256(lowerBound));
        // console2.log(uint256(upperBound));

        // bytes memory axiomResponse = loadCallData("evm/call_axiom_proof.hex");

        // SnarkedVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (SnarkedVault.ResponseStruct));
        // //console2.log(decoded.storageResponses[0].value);

        // dv.runStrat(proof, decoded);

        // (uint256 withdrawed0, uint256 withdrawed1) = dv.withdraw(shares / 2, 0.49 ether, 0.49 ether, address(this));
        // assert(IERC20(USDC).balanceOf(address(this)) == 99 ether + withdrawed0);
        // assert(IERC20(WETH).balanceOf(address(this)) == 99 ether + withdrawed1);
    }
}
