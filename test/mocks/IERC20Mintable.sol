// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.6;
pragma abicoder v2;

interface IERC20Mintable {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) external returns (bool);
}
