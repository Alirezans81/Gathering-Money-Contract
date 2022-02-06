pragma solidity >=0.5.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TheToken is ERC20 {
    constructor() public {
        totalSupply = 1000;
        balances[msg.sender] = 1000;
    }

    
}