// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma abicoder v2;

contract SnarkedKPIVault {
    mapping(bytes32 => uint256) publicKPI;
    mapping(bytes32 => address) privateKPIVerifierAddress;
    mapping(bytes32 => bytes32) privateKPICommitment;
    mapping(bytes32 => uint256) privateKPIStatistics;

    function getKPIKey(address company, uint256 kpiId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(company, kpiId));
    }

    function addPublicKPI(address company, uint256 kpiId, uint256 value) external {
        bytes32 kpiKey = getKPIKey(company, kpiId);
        publicKPI[kpiKey] = value;
    }

    function getPublicKPI(address company, uint256 kpiId) public view returns (uint256) {
        return publicKPI[keccak256(abi.encodePacked(company, kpiId))];
    }

    function setKPIVerfier(address company, uint256 kpiId, address verifier) external {
        bytes32 kpiKey = getKPIKey(company, kpiId);
        privateKPIVerifierAddress[kpiKey] = verifier;
    }

    function addPrivateKPI(address company, uint256 kpiId, bytes32 commitment, bytes calldata proof) external {
        bytes32 kpiKey = getKPIKey(company, kpiId);
        privateKPICommitment[kpiKey] = commitment;
        (bool success,) = privateKPIVerifierAddress[kpiKey].call(proof);
        if (!success) {
            revert("SnarkVerificationFailed");
        }
        uint256 provenStat = uint256(bytes32(proof[0:32]));
        privateKPIStatistics[kpiKey] = provenStat;
    }

    function getPrivateKPIStat(address company, uint256 kpiId) public view returns (uint256) {
        bytes32 kpiKey = getKPIKey(company, kpiId);
        return privateKPIStatistics[kpiKey];
    }
}
