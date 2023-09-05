// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Counter.sol";
import "../src/CCIPERC20.sol";

import "forge-std/console.sol";

contract CounterTest is Test {
    Counter public counter;
    CCIPERC20 public ccipERC20;

    address alice;

    function setUp() public {
        // sepolia router
        ccipERC20 = new CCIPERC20(0xD0daae2231E9CB96b94C8512223533293C3693Bf);
        counter = new Counter();
        counter.setNumber(0);
    }

    function testCCIPSend() public {
        // mint some tokens
        address alice = makeAddr("alice");

        ccipERC20.mint(address(alice));

        console.log("alice balance: %s", ccipERC20.balanceOf(alice));
    }
}
