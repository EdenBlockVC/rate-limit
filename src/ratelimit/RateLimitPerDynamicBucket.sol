pragma solidity ^0.8.16;

contract RateLimitPerDynamicBucket {
    // uint256 public rate;
    uint256 public bucketSize;

    // force minimum rate
    uint256 public minRate;

    // maximum increase denominator
    uint256 public denominator = type(uint256).max;

    mapping(uint256 => mapping(uint256 => uint256)) buckets;

    error RatePerBucketEnforced(uint256 ratePerBucketMax, uint256 amount);

    modifier enforceRatePerBucket(uint256 amount_) {
        uint256 bucketIndex = block.timestamp / bucketSize;
        uint256 currentBucket = buckets[bucketSize][bucketIndex];
        uint256 previousBucket = buckets[bucketSize][bucketIndex - 1];

        // Add a percent max increase per bucket
        uint256 previousBucketMax = previousBucket + previousBucket / denominator;

        // Enforce a minimum rate
        if (previousBucketMax < minRate) {
            previousBucketMax = minRate;
        }

        // Enforce rate per bucket
        if ((currentBucket + amount_) > previousBucketMax) {
            revert RatePerBucketEnforced(previousBucketMax, amount_);
        }

        // Update cumulative amount
        buckets[bucketSize][bucketIndex] += amount_;

        // Allow execution
        _;
    }

    function _setRatePerDynamicBucket(uint256 rate_, uint256 bucketSize_) internal {
        // Set bucket size
        bucketSize = bucketSize_;

        // Set current rate
        uint256 bucketIndex = block.timestamp / bucketSize_;
        buckets[bucketSize_][bucketIndex] = 0;
        buckets[bucketSize_][bucketIndex - 1] = rate_;

        // Save min rate
        minRate = rate_;
    }

    function _setBucketIncreaseDenominator(uint256 denominator_) internal {
        // Set denominator
        denominator = denominator_;
    }
}
