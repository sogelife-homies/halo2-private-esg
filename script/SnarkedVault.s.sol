// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/Base.sol";
import "../contracts/SnarkedVault.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "openzeppelin/proxy/transparent/ProxyAdmin.sol";
import "forge-std/console.sol";

abstract contract Utils is ScriptBase {
    function compileVerifier() internal returns (bytes memory) {
        string memory bashCommand = "solc --yul evm/verifier.yul --bin | tail -1";

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

    function loadCallData(string memory callDataPath) internal returns (bytes memory callData) {
        string memory bashCmd =
            string(abi.encodePacked('cast abi-encode "f(bytes)" $(cat ', string(abi.encodePacked(callDataPath, ")"))));
        string[] memory inp = new string[](3);
        inp[0] = "bash";
        inp[1] = "-c";
        inp[2] = bashCmd;
        callData = abi.decode(vm.ffi(inp), (bytes));
    }
}

contract InitialDeploySnarkedVault is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();

        vm.startBroadcast(deployerPrivateKey);

        address verifier = deployContract(verifierBytecode);

        SnarkedVault vaultImplementation = new SnarkedVault();
        bytes memory initCallData = abi.encodeWithSelector(
            vaultImplementation.initialize.selector,
            SnarkedVaultParams({
                pool: vm.envAddress("POOL_ADDRESS"),
                stratVerfifierAddress: verifier,
                axiomV1QueryAddress: vm.envAddress("AXIOM_V1_QUERY_ADDRESS"),
                name: "ZK-MM LPs",
                symbol: "ZMLP",
                maxTotalSupply: type(uint256).max
            })
        );

        new TransparentUpgradeableProxy(address(vaultImplementation), vm.addr(deployerPrivateKey), initCallData);

        vm.stopBroadcast();
    }
}

contract UpdateSnarkedVaultImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        ITransparentUpgradeableProxy proxy =
            (ITransparentUpgradeableProxy)(payable(vm.envAddress("ACTUAL_DUMMY_VAULT")));
        ProxyAdmin admin = (ProxyAdmin)(vm.envAddress("ACTUAL_DUMMY_VAULT_PROXY_ADMIN"));

        vm.startBroadcast(deployerPrivateKey);

        SnarkedVault vaultImplementation = new SnarkedVault();

        admin.upgradeAndCall(proxy, address(vaultImplementation), "");

        vm.stopBroadcast();
    }
}

contract UpdateVerifier is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();
        SnarkedVault vault = (SnarkedVault)(vm.envAddress("ACTUAL_DUMMY_VAULT"));

        vm.startBroadcast(deployerPrivateKey);

        address verifier = deployContract(verifierBytecode);

        vault.setStratVerfifierAddress(verifier);

        vm.stopBroadcast();
    }
}

contract RunStrat is Script, Utils {
    function run() external {
        SnarkedVault dv = (SnarkedVault)(vm.envAddress("ACTUAL_DUMMY_VAULT"));
        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomResponse = loadCallData("evm/call_axiom_proof.hex");

        SnarkedVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (SnarkedVault.ResponseStruct));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        dv.runStrat(proof, decoded);

        vm.stopBroadcast();
    }
}

contract EncodeRunStrat is Script, Utils {
    function run() external {
        SnarkedVault dv = (SnarkedVault)(vm.envAddress("ACTUAL_DUMMY_VAULT"));
        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomResponse = loadCallData("evm/call_axiom_proof.hex");

        SnarkedVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (SnarkedVault.ResponseStruct));

        bytes memory callData = abi.encodeWithSelector(dv.runStrat.selector, proof, decoded);

        console.logBytes(callData);
    }
}
