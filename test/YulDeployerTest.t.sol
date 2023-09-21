// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {Test, console2} from "forge-std/Test.sol";

contract YulDeployerTest is Test {
    address public verifierAddress;

    function loadCallData(string memory callDataPath) public returns (bytes memory callData) {
        string memory bashCmd =
            string(abi.encodePacked('cast abi-encode "f(bytes)" $(cat ', string(abi.encodePacked(callDataPath, ")"))));
        string[] memory inp = new string[](3);
        inp[0] = "bash";
        inp[1] = "-c";
        inp[2] = bashCmd;
        callData = abi.decode(vm.ffi(inp), (bytes));
    }

    ///@param fileName - The file name of the Yul contract. For example, the file name for "Example.yul" is "Example"
    function compile(string memory fileName) public returns (bytes memory bytecode) {
        // string memory bashCommand = string.concat(
        //     'cast abi-encode "f(bytes)" $(solc --yul yul/', string.concat(fileName, ".yul --bin | tail -1)")
        // );

        string memory bashCommand = string(
            abi.encodePacked(
                'cast abi-encode "f(bytes)" $(solc --yul ', string(abi.encodePacked(fileName, ".yul --bin | tail -1)"))
            )
        );

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        bytecode = abi.decode(vm.ffi(inputs), (bytes));
    }

    ///@notice Compiles a Yul contract and returns the address that the contract was deployed to
    ///@notice If deployment fails, an error will be thrown
    ///@param bytecode - Yul contract's bytecode

    function deployContract(bytes memory bytecode) public returns (address) {
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(deployedAddress != address(0), "YulDeployer could not deploy contract");

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    function _testYulVerifierDeploy() public {
        bytes memory bytecode = compile("evm/verifier");
        verifierAddress = deployContract(bytecode);

        bytes memory proof = loadCallData("evm/call_data.hex");
        (bool success,) = verifierAddress.call(proof);
        if (!success) {
            revert("SnarkVerificationFailed");
        }
    }
}
