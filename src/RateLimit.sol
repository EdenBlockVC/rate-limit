pragma solidity ^0.8.16;

contract RateLimit {
    uint256 public ratePerSecond;
    uint256 public fixedRate;

    uint256 public lastTimestamp;

    error FixedRateEnforced(uint256 fixedRate_, uint256 amount_);

    modifier enforceFixedRate(uint256 amount_) {
        // Enforce limit
        if (amount_ > fixedRate) {
            revert FixedRateEnforced(fixedRate, amount_);
        }

        // Allow execution
        _;
    }

    function _setFixedRate(uint256 fixedRate_) internal {
        fixedRate = fixedRate_;
    }

    // modifier enforceRateLimitPerSecond(uint256 amount_) {
    //     // Make sure the rate is respected
    //     require(
    //         // Rate if the tx is executed
    //         amount / (block.timestamp - lastTimestamp)
    //         // Set rate
    //         <= ratePerSecond
    //     );

    //     // Save the last timestamp
    //     lastTimestamp = block.timestamp;

    //     // Allow execution
    //     _;
    // }

    // function _setRatePerSecond(uint256 ratePerSecond_) internal {
    //     // Set new rate
    //     ratePerSecond = ratePerSecond_;

    //     // Reset timestamp
    //     lastTimestamp = block.timestamp;
    // }
}
