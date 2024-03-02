// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";
import "./yul/YulDeployerTest.t.sol";
import "../contracts/SnarkedKPIVault.sol";
import "./BytesLib.sol";

contract SnarkedKPIVaultTest is YulDeployerTest {
    function outputStat(bytes calldata proof) public {
        console2.logBytes32(bytes32(proof[0:32]));
    }

    function testVerifyPublicKPI() public {
        SnarkedKPIVault vault = new SnarkedKPIVault();

        address company = address(0x1);
        uint256 kpiId = 1;
        uint256 value = 500;

        assertEq(vault.getPublicKPI(company, kpiId), 0);
        vault.addPublicKPI(company, kpiId, value);
        assertEq(vault.getPublicKPI(company, kpiId), value);
    }

    function testStdStat() public {
        SnarkedKPIVault vault = new SnarkedKPIVault();

        address verifierAddress = deployVerifier();

        address company = address(0x1);
        uint256 kpiId = 1;
        uint256 value = 500;

        vault.setKPIVerfier(company, kpiId, verifierAddress);

        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes32 publicWitness = (BytesLib.toBytes32(proof, 0));
        console2.logBytes32(publicWitness);

        uint256 x1 = 0x0000000000000000000000000000000000000000000000004000000000000000;
        uint256 x2 = 0x0000000000000000000000000000000000000000000000004ccccccccccccc00;
        uint256 x3 = 0x0000000000000000000000000000000000000000000000005999999999999800;
        uint256 x4 = 0x0000000000000000000000000000000000000000000000006666666666666800;
        uint256 salt = 0x123;

        assertEq(vault.getPrivateKPIStat(company, kpiId), 0);
        vault.addPrivateKPI(company, kpiId, keccak256(abi.encodePacked(x1, x2, x3, x4, salt)), proof);
        assertEq(vault.getPrivateKPIStat(company, kpiId), uint256(publicWitness));
    }

    function testVerificationFail() public {
        SnarkedKPIVault vault = new SnarkedKPIVault();

        address verifierAddress = deployVerifier();

        address company = address(0x1);
        uint256 kpiId = 1;
        uint256 value = 500;

        vault.setKPIVerfier(company, kpiId, verifierAddress);

        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes32 publicWitness = (BytesLib.toBytes32(proof, 0));
        proof[32] = 0;
        vm.expectRevert("SnarkVerificationFailed");

        vault.addPrivateKPI(company, kpiId, keccak256(abi.encodePacked(uint256(0))), proof);
    }
}
