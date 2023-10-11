// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/Base.sol";
import "../contracts/DummyVault.sol";
import "openzeppelin/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/console.sol";

abstract contract Utils is ScriptBase {
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

contract InitialDeployDummyVault is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();

        vm.startBroadcast(deployerPrivateKey);

        address verifier = deployContract(verifierBytecode);

        DummyVault vaultImplementation = new DummyVault();
        bytes memory initCallData = abi.encodeWithSelector(vaultImplementation.initialize.selector, DummyVaultParams({
            pool: vm.envAddress("POOL_ADDRESS"),
            baseThreshold: (int24)(vm.envInt("BASE_THRESHOLD")),
            limitThreshold: (int24)(vm.envInt("LIMIT_THRESHOLD")),
            fullRangeWeight: (uint24)(vm.envUint("FULL_RANGE_WEIGHT")),
            stratVerfifierAddress: verifier,
            axiomV1QueryAddress: vm.envAddress("AXIOM_V1_QUERY_ADDRESS"),
            name: "ZK-MM LPs",
            symbol: "ZMLP",
            maxTotalSupply: type(uint256).max
        }));
        
        new TransparentUpgradeableProxy(address(vaultImplementation), vm.addr(deployerPrivateKey), initCallData);

        vm.stopBroadcast();
    }
}

contract UpdateDummyVaultImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        ITransparentUpgradeableProxy proxy = (ITransparentUpgradeableProxy)(payable(vm.envAddress('ACTUAL_DUMMY_VAULT')));

        vm.startBroadcast(deployerPrivateKey);

        DummyVault vaultImplementation = new DummyVault();
        
        proxy.upgradeToAndCall(address(vaultImplementation), "0x");

        vm.stopBroadcast();
    }
}

contract UpdateVerifier is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();
        DummyVault vault = (DummyVault)(vm.envAddress('ACTUAL_DUMMY_VAULT'));

        vm.startBroadcast(deployerPrivateKey);

        address verifier = deployContract(verifierBytecode);

        vault.setStratVerfifierAddress(verifier);

        vm.stopBroadcast();
    }

}

contract RunStrat is Script, Utils {
    function run() external {
        DummyVault dv = (DummyVault)(vm.envAddress('ACTUAL_DUMMY_VAULT'));
        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomResponse =
            hex"86c169984056cbe342e68d30d33f5eb547a258824502753ab37c62fcecd0d37f";

        DummyVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (DummyVault.ResponseStruct));

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        dv.runStrat(proof, decoded);

        vm.stopBroadcast();
    }
}

contract EncodeRunStrat is Script, Utils {
    function run() external {
        DummyVault dv = (DummyVault)(vm.envAddress('ACTUAL_DUMMY_VAULT'));
        bytes memory proof = loadCallData("evm/call_data.hex");
        bytes memory axiomResponse =
            hex"86c169984056cbe342e68d30d33f5eb547a258824502753ab37c62fcecd0d37f";

        DummyVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (DummyVault.ResponseStruct));

        bytes memory callData = abi.encodeWithSelector(dv.runStrat.selector, proof, decoded);

        console.logBytes(callData);
    }
}
