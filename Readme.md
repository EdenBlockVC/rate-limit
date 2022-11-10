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

The problem with rate per second is that it leaves room for all the unused rate since the rate was set up, up until the present time. This creates a few problems:

- if the protocol was much more popular a while ago but not recently and a bunch of deposits sit in there, it might mean that the full rate per second was not used. This is because the rate per second is calculated since it was deposited, it's not bound by time slices (like a rate per second, reset every hour)
- if the rate is used up completely, it does not increase in over time automatically; the owner has to increase it themselves.

Which presents to opportunity for the next way to implement this protection 👇

### 🪣 Rate per dynamic bucket

The dynamic bucket approach helps increase the rate limit over time, as it is used. It's easier explained with an example so here it is:

- we set a rate per hour of 100 tokens
- we set a dynamic increase limit of 10%
- during the next hour the full 100 tokens are deposited
- because we have a dynamic increase limit of 10%, the next hour the rate per hour is increased by 10% to 110 tokens
- during the next hour the full 110 tokens are deposited
- because we have a dynamic increase limit of 10%, the next hour the rate per hour is increased by 10% to 121 tokens
- ...[rate increases over time as it is used up]

Having this dynamic limit we have a hard limit that also increases over time as the protocol is used.

There is also a minimum limit set to the prevent the rate from decreasing to zero. This limit is equal to the initially set limit of 100 tokens per hour.

Assume during an hour, no deposits were made. Typically the rate would decrease to zero, and the next hour would use the previous bucket size and add an additional 10% on top of that. Because the previous hour was not used at all, the cumulative rate is zero. However this would typically block the protocol from being used. To prevent this, the minimum limit is set to the initial limit of 100 tokens per hour.

If you're building something of this sort it makes sense to check out this implementation for reference to get some ideas on how to implement it.

To set the rate per time slot one should call the internal method `_setRatePerDynamicBucket(uint256 rate_, uint256 bucketSize_)`.

To set up an dynamic increase limit one should call the internal method `_setBucketIncreaseDenominator(uint256 dynamicIncreaseLimit_)`.

If you want to understand how this works in more detail, check out the [tests](test/StakePerDynamicBucket.t.sol) and the [implementation](src/ratelimit/RateLimitPerDynamicBucket.sol).
