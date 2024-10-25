//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import "test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 constant DECIMALS = 8;
    int256 constant initialAnswer = 2000e8;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155420) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getAnvil();
        }
    }

    struct NetworkConfig {
        address priceFeed;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x61Ec26aA57019C486B10502285c5A3D4A4750AD7});
        return sepoliaConfig;
    }

    function getAnvil() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {}
        vm.startBroadcast();
        MockV3Aggregator mockpriceFeed = new MockV3Aggregator(DECIMALS, initialAnswer);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockpriceFeed)});
        return anvilConfig;
    }
}
