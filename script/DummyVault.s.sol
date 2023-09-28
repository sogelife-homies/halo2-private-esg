// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/Base.sol";
import "../contracts/DummyVault.sol";
import "openzeppelin/proxy/TransparentUpgradeableProxy.sol";
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
            stratVerfifierAddress: verifier
        }));
        
        new TransparentUpgradeableProxy(address(vaultImplementation), vm.addr(deployerPrivateKey), initCallData);

        vm.stopBroadcast();
    }
}

contract UpdateDummyVaultImplementation is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        TransparentUpgradeableProxy proxy = (TransparentUpgradeableProxy)(payable(vm.envAddress('ACTUAL_DUMMY_VAULT')));

        vm.startBroadcast(deployerPrivateKey);

        DummyVault vaultImplementation = new DummyVault();
        
        proxy.upgradeTo(address(vaultImplementation));

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
            hex"00000000000000000000000000000000000000000000000000000000000000206000f5edcb28fd8a47a86fd708ce7ae05e0ccb524c659297e633abe8bfe58736a58b3021fdc4f7c6b45af00f1c9db3b9f51a061d4650fea4e260d90383fbed7a1b3633944a7d2eb24a2399be2a8179ad73cabd0f65c99c74763d492056164f7400000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b144fe76620a5a743c01709bf80a005ca314cff6c5f50939b5b7845d3ea9a94403f00000000000000000000000000000000000000000000000000000000000000003a087e59482812269efc4792327baa920bd01fd14468337ca3e2fd9b1397c350ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa9072200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000bd24cf192ee57af9c911cbba4664a6097746ac0603a5e237989266f3deffa51350cd42c33f06d13cd5fe3c57613bf2f330da95d6801bb1142a63dfd1a364d5b7000000000000000000000000000000000000000000000000000000000000000079e9499f0de3297006a300d48a6f1018f32f7f488a3f47eb6115db96798e090bad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa907220000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000101cc73a7fbeb427b026e8252ec723f8a900000000000000000000000000000000000000000000000000000000000000003f1d422a05bea118012fd9e48879fcca621beb11d455b72dc3b5aa2be2b6b53ead3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d";

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
            hex"00000000000000000000000000000000000000000000000000000000000000206000f5edcb28fd8a47a86fd708ce7ae05e0ccb524c659297e633abe8bfe58736a58b3021fdc4f7c6b45af00f1c9db3b9f51a061d4650fea4e260d90383fbed7a1b3633944a7d2eb24a2399be2a8179ad73cabd0f65c99c74763d492056164f7400000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003c000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b144fe76620a5a743c01709bf80a005ca314cff6c5f50939b5b7845d3ea9a94403f00000000000000000000000000000000000000000000000000000000000000003a087e59482812269efc4792327baa920bd01fd14468337ca3e2fd9b1397c350ad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa9072200000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000bd24cf192ee57af9c911cbba4664a6097746ac0603a5e237989266f3deffa51350cd42c33f06d13cd5fe3c57613bf2f330da95d6801bb1142a63dfd1a364d5b7000000000000000000000000000000000000000000000000000000000000000079e9499f0de3297006a300d48a6f1018f32f7f488a3f47eb6115db96798e090bad3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000931b140000000000000000000000000cc2b3664c913f8443cf5404b460763dbaa907220000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000101cc73a7fbeb427b026e8252ec723f8a900000000000000000000000000000000000000000000000000000000000000003f1d422a05bea118012fd9e48879fcca621beb11d455b72dc3b5aa2be2b6b53ead3228b676f7d3cd4284a5443f17f1962b36e491b30a40b2405849e597ba5fb5b4c11951957c6f8f642c4af61cd6b24640fec6dc7fc607ee8206a99e92410d3021ddb9a356815c3fac1026b6dec5df3124afbadb485c9ba5a3e3398a04b7ba85e58769b32a1beaf1ea27375a44095a0d1fb664ce2dd358e7fcbfb78c26a193440eb01ebfc9ed27500cd4dfc979272d1f0913cc9f66540d7e8005811109e1cf2d";

        DummyVault.ResponseStruct memory decoded = abi.decode(axiomResponse, (DummyVault.ResponseStruct));

        bytes memory callData = abi.encodeWithSelector(dv.runStrat.selector, proof, decoded);

        console.logBytes(callData);
    }
}
