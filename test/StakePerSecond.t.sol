// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import {Stake} from "src/stake/StakePerSecond.sol";

import {ERC20Mintable} from "src/token/ERC20Mintable.sol";

contract StakePerSecondTest is Test {
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
    }

    function testDepositWithinPerSecondLimit_isSuccessful(uint256 amount) public {
        uint256 ratePerSecond = 10;
        stake.setRatePerSecond(ratePerSecond);

        // Travel 1 second in the future to make some room for new deposits
        vm.warp(block.timestamp + 1);

        // Enforce fuzzer to limit amount to a valid rate
        vm.assume(amount <= ratePerSecond);

        // Deposit an amount within the rate per second constraints
        stake.depositWithRatePerSecond(amount);
    }

    function testFailDepositWithinRatePerSecond_enforcesLimit(uint256 amount) public {
        uint256 ratePerSecond = 10;
        stake.setRatePerSecond(ratePerSecond);

        // Travel 1 second in the future to make some room for new deposits
        vm.warp(block.timestamp + 1);

        // Enforce fuzzer to set amount over the valid rate
        vm.assume(amount > ratePerSecond);

        // Deposit should fail since the amount is over the valid rate
        stake.depositWithRatePerSecond(amount);
    }

    function testDepositWithinRatePerSecond_allowsMultipleActionsWithinConstraints() public {
        uint256 ratePerSecond = 10;
        stake.setRatePerSecond(ratePerSecond);

        // Travel 1 second in the future to make some room for new deposits
        vm.warp(block.timestamp + 1);

        // Multiple actions within the rate should be successful
        stake.depositWithRatePerSecond(ratePerSecond / 2);
        stake.depositWithRatePerSecond(ratePerSecond / 2);
    }

    function testFailDepositWithinRatePerSecond_blocksMultipleActionsOutsideOfConstraints() public {
        uint256 ratePerSecond = 10;
        stake.setRatePerSecond(ratePerSecond);

        // Travel 1 second in the future to make some room for new deposits
        vm.warp(block.timestamp + 1);

        // This action is within constraints
        stake.depositWithRatePerSecond(ratePerSecond);

        // This action pushes over the rate
        stake.depositWithRatePerSecond(1);
    }
}
