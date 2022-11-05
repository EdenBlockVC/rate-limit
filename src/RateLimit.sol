pragma solidity ^0.8.16;

contract RateLimit {
    /// --- Rate per action --- ///

    uint256 public ratePerAction;

    error FixedRateEnforced(uint256 ratePerAction_, uint256 amount_);

    modifier enforceRatePerAction(uint256 amount_) {
        // Enforce limit
        if (amount_ > ratePerAction) {
            revert FixedRateEnforced(ratePerAction, amount_);
        }

        // Allow execution
        _;
    }

    function _setRatePerAction(uint256 ratePerAction_) internal {
        ratePerAction = ratePerAction_;
    }

    /// --- Rate per second --- ///

    uint256 public ratePerSecond;

    uint256 public initialTimestamp;
    uint256 public cumulativeAmount;

    error RatePerSecondEnforced(uint256 ratePerSecond, uint256 amountBreakingLimit);

    modifier enforceRatePerSecond(uint256 amount_) {
        // Enforce limit
        if (
            (cumulativeAmount + amount_) / (block.timestamp - initialTimestamp) >
            ratePerSecond
        ) {
            revert RatePerSecondEnforced(ratePerSecond, amount_);
        }

        // Update cumulative amount
        cumulativeAmount += amount_;

        // Allow execution
        _;
    }

    function _setRatePerSecond(uint256 ratePerSecond_) internal {
        // Set new rate
        ratePerSecond = ratePerSecond_;

        // Reset timestamp
        initialTimestamp = block.timestamp;

        // Reset amount
        cumulativeAmount = 0;
    }
}
