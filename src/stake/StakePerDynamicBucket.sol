pragma solidity ^0.8.16;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {RateLimitPerDynamicBucket} from "src/ratelimit/RateLimitPerDynamicBucket.sol";

contract Stake is RateLimitPerDynamicBucket {
    // balances stores how many tokens each user deposited
    mapping(address => uint256) public balances;

    // owner defines an account with special permissions
    address public owner;

    // OnlyOwner is emitted when someone else tried to a protected method
    error OnlyOwner(address owner, address caller);

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

    // setRatePerHour defines a maximum rate allowed per hour
    function setRatePerDynamicBucket(uint256 rate_, uint256 bucketSize_) public {
        // Only the owner can change the rate
        checkCaller();

        _setRatePerDynamicBucket(rate_, bucketSize_);
    }

    function setBucketIncreaseDenominator(uint256 denominator_) public {
        // Only the owner can change the rate
        checkCaller();

        _setBucketIncreaseDenominator(denominator_);
    }

    // deposit allows the user to deposit tokens enforcing the rate per bucket hour allowed
    function deposit(uint256 amount_) public enforceRatePerBucket(amount_) {
        token.transferFrom(msg.sender, address(this), amount_);

        balances[msg.sender] += amount_;
    }
}
