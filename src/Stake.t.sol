// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "./Stake.sol";

import {ERC20Mintable} from "./token/ERC20Mintable.sol";

contract StakeTest is Test {
    Stake public stake;
    ERC20Mintable public token;

    uint256 internal amountTotal = 1000;
    uint256 internal amountToStake;

    function setUp() public {
        token = new ERC20Mintable("Test", "TST");
        stake = new Stake(token);

        token.mint(address(this), amountTotal);
        token.approve(address(stake), amountTotal);
    }

    function testSetFixedRate() public {
        stake.setFixedRate(10);
        assertEq(stake.fixedRate(), 10);
    }

    function testDepositWithinFixedRate(uint256 amount) public {
        uint256 ratePerSecond = 10;
        stake.setFixedRate(ratePerSecond);

        vm.assume(amount <= ratePerSecond);

        stake.depositWithFixedRate(amount);
    }

    function testFailDepositWithFixedRateEnforcesLimit(uint256 amount) public {
        uint256 ratePerSecond = 10;
        stake.setFixedRate(ratePerSecond);

        vm.assume(amount > ratePerSecond);

        stake.depositWithFixedRate(amount);
    }

    // function testSetRatePerSecond() public {
    //     stake.setRatePerSecond(10);
    //     assertEq(stake.ratePerSecond(), 10);
    // }

    // function testDepositTooQuickly() public {
    //     uint256 maxRatePerSecond = 10;
    //     stake.setRatePerSecond(maxRatePerSecond);

    //     // Move moment in time
    //     // vm.warp(block.timestamp + 1);

    //     // First deposit should work correctly
    //     // and it will use the full set rate
    //     stake.deposit(maxRatePerSecond + 1);

    //     // Second deposit in the same block should fail
    //     // because it breaks the rate limit
    //     stake.deposit(1);
    // }
}
