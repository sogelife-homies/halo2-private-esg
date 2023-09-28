// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import "../contracts/DummyVault.sol";

contract DeployDummyVault is Script {
    function compileVerifier() internal returns (bytes memory) {

        string memory bashCommand = 'solc --yul evm/verifier.yul --bin | tail -1';

        string[] memory inputs = new string[](3);
        inputs[0] = "bash";
        inputs[1] = "-c";
        inputs[2] = bashCommand;

        return vm.ffi(inputs);
    }

    function deployContract(bytes memory bytecode) internal returns (address) {
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        ///@notice check that the deployment was successful
        require(deployedAddress != address(0), "YulDeployer could not deploy contract");

        ///@notice return the address that the contract was deployed to
        return deployedAddress;
    }

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();

        vm.startBroadcast(deployerPrivateKey);

        DummyVault vault = new DummyVault();

        address verifier = deployContract(verifierBytecode);

        vault.initialize(DummyVaultParams({
            pool: vm.envAddress("POOL_ADDRESS"),
            baseThreshold: (int24)(vm.envInt("BASE_THRESHOLD")),
            limitThreshold: (int24)(vm.envInt("LIMIT_THRESHOLD")),
            fullRangeWeight: (uint24)(vm.envUint("FULL_RANGE_WEIGHT")),
            stratVerfifierAddress: verifier
        }));

        vm.stopBroadcast();
    }
}
