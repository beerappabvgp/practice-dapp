// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20, Ownable {
    // Pass the token name ("MyToken") and token symbol ("MTK") to the constructor of ERC20.
    constructor() ERC20("MyToken", "MTK") {
        
    }

    // Mint function, only callable by the owner.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
