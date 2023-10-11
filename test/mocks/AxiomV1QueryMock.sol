// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;
pragma abicoder v2;

contract AxiomV1QueryMock {
    uint32 constant QUERY_MERKLE_DEPTH = 6;

    struct BlockResponse {
        uint32 blockNumber;
        bytes32 blockHash;
        uint32 leafIdx;
        bytes32[QUERY_MERKLE_DEPTH] proof;
    }

    struct AccountResponse {
        uint32 blockNumber;
        address addr;
        uint64 nonce;
        uint96 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
        uint32 leafIdx;
        bytes32[QUERY_MERKLE_DEPTH] proof;
    }

    struct StorageResponse {
        uint32 blockNumber;
        address addr;
        uint256 slot;
        uint256 value;
        uint32 leafIdx;
        bytes32[QUERY_MERKLE_DEPTH] proof;
    }

    function areResponsesValid(
        bytes32 keccakBlockResponse,
        bytes32 keccakAccountResponse,
        bytes32 keccakStorageResponse,
        BlockResponse[] calldata blockResponses,
        AccountResponse[] calldata accountResponses,
        StorageResponse[] calldata storageResponses
    ) external view returns (bool) {
        return true;
    }
}
