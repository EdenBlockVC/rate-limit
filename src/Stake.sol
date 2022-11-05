pragma solidity ^0.8.16;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {RateLimit} from "./RateLimit.sol";

contract Stake is RateLimit {
    // balances stores how many tokens each user deposited
    mapping(address => uint256) public balances;

    // owner defines an account with special permissions
    address public owner;

    // OnlyOwner is emitted when someone else tried to a protected method
    error OnlyOwner(address owner,address caller);

    // checkCaller reverts if the caller is not the owner
    function checkCaller() private view {
        if (owner != msg.sender) {
            revert OnlyOwner(owner, msg.sender);
        }
    }

    // token is the ERC20 compatible token which can be deposited
    IERC20 public token;

    constructor(IERC20 token_) {
        // Set the token
        token = token_;

        // Set the owner
        owner = msg.sender;
    }

    /// --- Rate per action --- ///

    // setRatePerAction defines a maximum rate allowed per action
    function setRatePerAction(uint256 ratePerAction_) public {
        // Only the owner can change the rate
        checkCaller();

        _setRatePerAction(ratePerAction_);
    }

    // depositWithRatePerAction allows the user to deposit tokens enforcing the max rate allowed per action
    function depositWithRatePerAction(uint256 amount_) public enforceRatePerAction(amount_) {
        token.transferFrom(msg.sender, address(this), amount_);

        balances[msg.sender] += amount_;
    }

    /// --- Rate per second --- ///

    // setRatePerSecond defines a maximum rate allowed per second 
    function setRatePerSecond(uint256 ratePerSecond_) public {
        // Only the owner can change the rate
        checkCaller();

        _setRatePerSecond(ratePerSecond_);
    }

    // depositWithRatePerSecond allows the user to deposit tokens enforcing the rate per second allowed
    function depositWithRatePerSecond(uint amount_) public enforceRatePerSecond(amount_) {
        token.transferFrom(msg.sender, address(this), amount_);

        balances[msg.sender] += amount_;
    }
}
