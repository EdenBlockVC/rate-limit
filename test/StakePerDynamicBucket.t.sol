// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import {Stake} from "src/stake/StakePerDynamicBucket.sol";

import {ERC20Mintable} from "src/token/ERC20Mintable.sol";

contract StakePerDynamicBucketTest is Test {
    Stake public stake;
    ERC20Mintable public token;

    uint256 internal amountTotal = 1000;
    uint256 internal amountToStake;

    function setUp() public {
        token = new ERC20Mintable("Test", "TST");
        stake = new Stake(token);

        // Create tokens and allow all of them to be used by the staking contract
        token.mint(address(this), amountTotal);
        token.approve(address(stake), amountTotal);

        // Move time in advance to leave room for a previous bucket
        vm.warp(3600 * 1);
    }

    function testDeposit_isSuccessful() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Deposit an amount within the rate constraints
        uint256 amount = ratePerBucket;
        stake.deposit(amount);
    }

    function testMultipleDeposits_isSuccessful() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Deposit an amount within the rate constraints
        uint256 amount = ratePerBucket;
        stake.deposit(amount / 2);
        stake.deposit(amount / 2);
    }

    function testFailDepositAboveRate_enforcesLimit() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Deposit an amount above rate constraints
        uint256 amount = ratePerBucket + 1;
        stake.deposit(amount);
    }

    function testDepositWithinIncreaseLimit_isSuccessful() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Set max increase per bucket
        stake.setBucketIncreaseDenominator(10); // 10%

        // Deposit an amount above the rate constraints
        // but within max increase per bucket
        uint256 amount = ratePerBucket + (ratePerBucket / 10);
        stake.deposit(amount);
    }

    function testMultipleDepositsWithinIncreaseLimit_isSuccessful() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Set max increase per bucket
        stake.setBucketIncreaseDenominator(10); // 10%

        // Deposit an amount above the rate constraints
        // but within max increase per bucket
        uint256 amount = ratePerBucket + (ratePerBucket / 10);
        stake.deposit(amount);

        // Move into the future to make sure a 3rd bucket is created
        vm.warp(block.timestamp + bucketSize);

        // New max amount within increase limit
        amount = amount + (amount / 10);
        stake.deposit(amount);
    }

    function testFailDepositAboveIncreaseLimit_enforcesLimit() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Set max increase per bucket
        stake.setBucketIncreaseDenominator(10); // 10%

        // Deposit an amount above the rate constraints
        // and above max increase per bucket
        uint256 amount = ratePerBucket + (ratePerBucket / 10) + 1;
        stake.deposit(amount);
    }

    function testDeposit_afterABucketIsSkipped_enforcesAMinLimit() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);

        // Deposit an amount above the rate constraints
        // but within max increase per bucket
        uint256 amount = ratePerBucket;
        stake.deposit(amount);

        // Move into the future to make sure we skip a bucket
        // thus having a bucket with 0 rate limit
        vm.warp(block.timestamp + bucketSize * 2);

        // Deposit the initial rate should be successful
        stake.deposit(amount);
    }

    function testFailDeposit_afterABucketIsSkipped_enforcesInitialLimit() public {
        // Set rate
        uint256 ratePerBucket = 100;
        uint256 bucketSize = 3600; // 1 hour
        stake.setRatePerDynamicBucket(ratePerBucket, bucketSize);
        stake.setBucketIncreaseDenominator(10); // 10%

        // Deposit an amount above the rate constraints
        // but within max increase per bucket
        uint256 amount = ratePerBucket;
        stake.deposit(amount);

        // Move into the future to make sure we skip a bucket
        // thus having a bucket with 0 rate limit between actions
        vm.warp(block.timestamp + bucketSize * 2);

        // Depositing initial rate + 1 should fail
        stake.deposit(amount + 1);
    }
}
