// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe public fundMe;
    address USER = makeAddr("user"); //用作弊码创建的一个用户
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    modifier funded() {
        //避免代码重复
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        DeployFundMe deployment = new DeployFundMe();
        fundMe = deployment.run();
        vm.deal(USER, STARTING_BALANCE); //铸造一些代币给用户
    }

    function testUserCanFund() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance == 0);
    }
}
