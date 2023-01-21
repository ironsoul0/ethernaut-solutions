// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import "../src/Counter.sol";

contract CounterScript is Script {
  Counter public counter;

  function run() public {
    vm.startBroadcast();

    counter = new Counter();
    counter.setNumber(0);
    console.log("Contract was deployed to %s", address(counter));

    vm.stopBroadcast();
  }
}
