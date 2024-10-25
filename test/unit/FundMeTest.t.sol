pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
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

    function test_constant() public {
        console.log("FundMe address in test_constant:", address(fundMe));
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsSender() public {
        console.log("FundMe address in testOwnerIsSender:", address(fundMe));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testConvert() public {
        console.log("FundMe address in testConvert:", address(fundMe));
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testSendFundFaileded() public {
        vm.expectRevert(); //预期下面的操作会回退，来测试判断条件
        fundMe.fund();
    }

    function testFundUpdates() public {
        vm.prank(USER); //下面的交易将会由USER这个用户发送
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFunderToArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    //不懂
    function testWithdrawWithOwner() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        //Act
        uint256 gas_start = gasleft();
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gas_end = gasleft();
        uint256 gas_used = (gas_start - gas_end) * tx.gasprice;
        console.log(gas_used);
        //Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testMultiFunders() public {
        uint160 numberOfFunders = 10; //使用 uint160 的原因是因为该位数与地址位数是一样的，所以最终可以进行。如果使用的是uint256类型的，则必须先转换成uint160类型的才可以
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i <= numberOfFunders; ++i) {
            hoax(address(i), SEND_VALUE); //hoax 融合了 prank方法和deal方法
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        assertEq(address(fundMe).balance, 0);
    }
}
