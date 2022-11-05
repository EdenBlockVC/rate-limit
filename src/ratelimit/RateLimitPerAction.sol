pragma solidity ^0.8.16;

contract RateLimitPerAction {
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
}
