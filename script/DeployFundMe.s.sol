pragma solidity ^0.8.18;

import { Script, console } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe) {
        //run函数是默认进行合约部署的
        HelperConfig config = new HelperConfig(); //在这个合约部署的时候，使用了 block.chainid ，就会自动识别部署的链id
        address priceFeedEth_USTD = config.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedEth_USTD);
        vm.stopBroadcast();
        return fundMe;
    }
}
