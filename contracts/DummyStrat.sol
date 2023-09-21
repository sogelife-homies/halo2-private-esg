// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "openzeppelin/access/Ownable.sol";

contract DummyStrat is Ownable {
    address public verifierAddress;

    constructor(address _verifierAddress) Owned(msg.sender) {
        require(_verifierAddress != address(0), "No verifier");
        verifierAddress = _verifierAddress;
    }

    function setVerifierAddress(address _verifierAddress) external onlyOwner {
        verifierAddress = _verifierAddress;
    }

    function _validateStorageProof(ResponseStruct calldata axiomResponse) private view {
        IAxiomV1Query axiomV1Query = IAxiomV1Query(AXIOM_V1_QUERY_GOERLI_ADDR);

        bool valid = axiomV1Query.areResponsesValid(
            axiomResponse.keccakBlockResponse,
            axiomResponse.keccakAccountResponse,
            axiomResponse.keccakStorageResponse,
            axiomResponse.blockResponses,
            axiomResponse.accountResponses,
            axiomResponse.storageResponses
        );
        if (!valid) {
            revert("StorageProofValidationError");
        }
    }

    function runStrat(bytes calldata proof, ResponseStruct calldata axiomResponse) public {
        // Extract instances from proof
        // The public instances are laid out in the proof calldata as follows:
        // First 4 * 3 * 32 = 384 bytes are reserved for proof verification data used with the pairing precompile
        // 384..384 + 32 * 2: blockHash (32 bytes) as two uint128 cast to uint256, because zk proof uses 254 bit field and cannot fit uint256 into a single element
        // 384 + 32 * 2..384 + 32 * 3: blockNumber as uint256
        // 384 + 32 * 3..384 + 32 * 4: address as uint256
        // Followed by SLOT_NUMBER pairs of (slot, value)s, where slot: bytes32, value: uint256 laid out as:
        // index..index + 32 * 2: `slot` (32 bytes) as two uint128 cast to uint256, same as blockHash
        // index + 32 * 2..index + 32 * 4: `value` (32 bytes) as two uint128 cast to uint256, same as blockHash
        uint256 _blockHash = (uint256(bytes32(proof[384:384 + 32])) << 128) | uint128(bytes16(proof[384 + 48:384 + 64]));
        uint256 _blockNumber = uint256(bytes32(proof[384 + 64:384 + 96]));
        address account = address(bytes20(proof[384 + 108:384 + 128]));

        (bool success,) = verifierAddress.call(proof);
        if (!success) {
            revert("SnarkVerificationFailed");
        }
    }
}
