// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import "openzeppelin/token/ERC20/ERC20.sol";
import "./IERC20Mintable.sol";

contract MockERC20 is ERC20, IERC20Mintable {
    constructor() ERC20("Token", "ZAMM_USDC") {}

    function mint(address account, uint256 amount) public override returns (bool) {
        _mint(account, amount);
        return true;
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
