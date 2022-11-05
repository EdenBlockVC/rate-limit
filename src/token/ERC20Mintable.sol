pragma solidity ^0.8.16;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract ERC20Mintable is ERC20 {
    address public owner;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        owner = msg.sender;
    }

    function mint(address account, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint");

        _mint(account, amount);
    }
}
