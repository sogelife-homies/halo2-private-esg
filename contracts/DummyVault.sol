// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "openzeppelin/access/Ownable.sol";
import "./interfaces/IAxiomV1Query.sol";
import "./libraries/BytesLib.sol";

contract DummyVault is Ownable {
    struct ResponseStruct {
        bytes32 keccakBlockResponse;
        bytes32 keccakAccountResponse;
        bytes32 keccakStorageResponse;
        IAxiomV1Query.BlockResponse[] blockResponses;
        IAxiomV1Query.AccountResponse[] accountResponses;
        IAxiomV1Query.StorageResponse[] storageResponses;
    }

    event RebalanceData(uint32 blockNumber, address addr, uint256 slot, uint256 value);

    address public axiomV1QueryAddress = 0x4Fb202140c5319106F15706b1A69E441c9536306;

    address public stratVerfifierAddress;

    constructor(address _stratVerfifierAddress) Ownable() {
        require(_stratVerfifierAddress != address(0), "No verifier");
        stratVerfifierAddress = _stratVerfifierAddress;
    }

    function setAxiomV1QueryAddress(address _axiomV1QueryAddress) external onlyOwner {
        axiomV1QueryAddress = _axiomV1QueryAddress;
    }

    function setStratVerfifierAddress(address _stratVerfifierAddress) external onlyOwner {
        stratVerfifierAddress = _stratVerfifierAddress;
    }

    function _validateStorageProof(ResponseStruct calldata axiomResponse) private view {
        IAxiomV1Query axiomV1Query = IAxiomV1Query(axiomV1QueryAddress);

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
        // uint256 _blockHash = (uint256(bytes32(proof[384:384 + 32])) << 128) | uint128(bytes16(proof[384 + 48:384 + 64]));
        // uint256 _blockNumber = uint256(bytes32(proof[384 + 64:384 + 96]));
        // address account = address(bytes20(proof[384 + 108:384 + 128]));

        // uint256 _blockHash =
        //     (uint256(BytesLib.toBytes32(proof, 384)) << 128) | uint128(BytesLib.toBytes16(proof, 384 + 48));
        // uint256 _blockNumber = uint256(bytes32(proof[384 + 64:384 + 96]));
        // address account = address(bytes20(proof[384 + 108:384 + 128]));
        //revert("SnarkVerificationFailed");
        _validateStorageProof(axiomResponse);
        (bool success,) = stratVerfifierAddress.call(proof);
        if (!success) {
            revert("SnarkVerificationFailed");
        }
    }
}
