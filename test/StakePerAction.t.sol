// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import {Stake} from "src/stake/StakePerAction.sol";

import {ERC20Mintable} from "src/token/ERC20Mintable.sol";

contract StakePerActionTest is Test {
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

    function test_SetRatePerAction() public {
        stake.setRatePerAction(10);
        assertEq(stake.ratePerAction(), 10);
    }

    function test_DepositWithinRatePerAction_isSuccessful(uint256 amount) public {
        uint256 ratePerAction = 10;
        stake.setRatePerAction(ratePerAction);

        // Enforce fuzzer to limit amount to a valid rate
        vm.assume(amount <= ratePerAction);

        // Deposit an amount within the rate per action constraints
        stake.depositWithRatePerAction(amount);
    }

    function testFail_DepositWithRatePerAction_enforcesLimit(uint256 amount) public {
        uint256 ratePerAction = 10;
        stake.setRatePerAction(ratePerAction);

        // Enforce fuzzer to set amount over the valid rate
        vm.assume(amount > ratePerAction);

        // Deposit should fail since the amount is over the valid rate
        stake.depositWithRatePerAction(amount);
    }

    function testFail_DepositWithRatePerAction_enforcesLimit() public {
        uint256 ratePerAction = 10;
        stake.setRatePerAction(ratePerAction);

        // Deposit should fail since the amount is over the valid rate
        stake.depositWithRatePerAction(ratePerAction + 1);
    }
}
