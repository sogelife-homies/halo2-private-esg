// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
pragma abicoder v2;

library BytesLib {
    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }

    function toBytes16(bytes memory _bytes, uint256 _start) internal pure returns (bytes16) {
        require(_bytes.length >= _start + 16, "toBytes16_outOfBounds");
        bytes16 tempBytes16;

        assembly {
            tempBytes16 := mload(add(add(_bytes, 0x10), _start))
        }

        return tempBytes16;
    }
}
