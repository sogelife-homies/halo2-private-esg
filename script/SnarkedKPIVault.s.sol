// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "forge-std/Script.sol";
import "forge-std/Base.sol";
import "../contracts/SnarkedKPIVault.sol";
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

contract SnarkedKPIVaultScript is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("EVM_PRIVATE_KEY");

        bytes memory verifierBytecode = compileVerifier();

        vm.startBroadcast(deployerPrivateKey);

        address verifier = deployContract(verifierBytecode);
        SnarkedKPIVault vault = new SnarkedKPIVault();

        address company = address(0xE46DB4484E7eF0177Cc5e672d554DeDcEC0Bee3b);
        uint256 kpiId = 1;
        uint256 value = 500;
        vault.setKPIVerfier(company, kpiId, verifier);

        vault.addPublicKPI(company, kpiId, value);

        uint256 x1 = 0x0000000000000000000000000000000000000000000000004000000000000000;
        uint256 x2 = 0x0000000000000000000000000000000000000000000000004ccccccccccccc00;
        uint256 x3 = 0x0000000000000000000000000000000000000000000000005999999999999800;
        uint256 x4 = 0x0000000000000000000000000000000000000000000000006666666666666800;
        uint256 salt = 0x123;

        bytes memory proof = loadCallData("evm/call_data.hex");

        vault.addPrivateKPI(company, kpiId, keccak256(abi.encodePacked(x1, x2, x3, x4, salt)), proof);
        vm.stopBroadcast();
    }
}

contract AddKPIVaultScript is Script, Utils {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("EVM_PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        SnarkedKPIVault vault = SnarkedKPIVault(0xd6Ec7C42cC35B8419e398cFe29684baEAb0c2F9d);

        address company = address(0xE46DB4484E7eF0177Cc5e672d554DeDcEC0Bee3b);
        uint256 kpiId = 1;
        uint256 value = 400;

        vault.addPublicKPI(company, kpiId, value);
        vault.addPublicKPI(company, 2, 12500);
        vault.addPublicKPI(company, 3, 5);
        vault.addPublicKPI(company, 4, 50);
        vault.addPublicKPI(company, 5, 50);
        vault.addPublicKPI(company, 6, 50000);

        vm.stopBroadcast();
    }
}
