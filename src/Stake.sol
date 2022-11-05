pragma solidity ^0.8.16;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {RateLimit} from "./RateLimit.sol";

contract Stake is RateLimit {
    mapping(address => uint256) public balances;

    IERC20 public token;

    constructor(IERC20 token_) {
        token = token_;
    }

    function setFixedRate(uint256 ratePerSecond_) public {
        _setFixedRate(ratePerSecond_);
    }

    function depositWithFixedRate(uint256 amount) public enforceFixedRate(amount) {
        token.transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
    }
}
