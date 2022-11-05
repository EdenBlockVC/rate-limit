# 🚤 Rate limit

Proof of concept which implements rate limits for smart contracts dealing with ERC20-compatible tokens.

The purpose of this contract is to provide an example of how a developer can set limits for their own protocol to limit the damage a hack can do. It does not protect from hacks itself, but it can limit the damage caused by it.

Below we go through a few ways of implementing this, each with their own upsides and downsides.

The following repository is meant to serve as an educational experience for any developer trying to set rate limits in their protocol.

## 😮‍💨 Disclaimer

The code is not gas optimized and is does not try to implement the concept in the best way possible, its purpose is to describe a way to implement rate limits.

There might be errors or security issues and this code should not be used in production as it is now.

However, it does implement unit testing which gives a small amount of certainty that it behaves correctly. More testing and reviewing should be done before it can be considered okay to be used in production.

## 💬 Description

This is a proof of concept / educational repository that shows how you can implement a rate limiter in a protocol that enforces token transfer limits based on specified rates.

Feature list:

- [x] rate per action
- [x] rate per second

To enfoce the limit, a modifier is provided which can be added to the methods to be protected.

As an example, if the rate per action wants to be enforced, the modifier `enforceRatePerAction(amount)` can be added to the `stake(uint amount)` method.

### 💻 Navigating the code

Examples on how each rate limit can be enforced are found in:

- [StakePerAction.sol](./src/stake/StakePerAction.sol)
- [StakePerSecond.sol](./src/stake/StakePerSecond.sol)

The corresponding contract implementing the rate limits are:

- [RateLimitPerAction.sol](./src/ratelimit/RateLimitPerAction.sol)
- [RateLimitPerSecond.sol](./src/ratelimit/RateLimitPerSecond.sol)

The unit tests and fuzzing tests are found in:

- [StakePerAction.t.sol](./src/StakePerAction.t.sol)
- [StakePerSecond.t.sol](./src/StakePerSecond.t.sol)

### 🕺 Rate per action

This rate can be set by calling the `internal` method `RateLimitPerAction._setRatePerAction(uint256 ratePerAction_)` to define a hard maximum limit per action.

The action can be protected by using the modifier `enforceRatePerAction(uint256 amount_)` which checks if the specified amount is lower or equal to the set rate per action. If the condition is not met, the transaction reverts.

Of course, an attacker could split their action into multiple actions which stay below the specified limit. Inherently, this type of protection is exposed to action splitting, which in practice doesn't protect too much from a malicious actor who found an exploit in the system.

### ⏲️ Rate per second

This rate can be set by calling the `internal` method `RateLimitPerSecond._setRatePerSecond(uint256 ratePerSecond_)` to define a hard maximum limit per second since the limit was set.

The action can be protected by using the modifier `enforceRatePerSecond(uint256 amount_)` which checks if the cumulative amount of deposited tokens obeys the specified rate per second limit since the limit was defined.
