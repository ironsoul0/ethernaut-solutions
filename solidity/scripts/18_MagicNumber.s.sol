// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

/*
Deployment code:

CODESIZE
PUSH1 0x00
PUSH1 0x00
CODECOPY
PUSH1 0x0a
PUSH1 0x0b
RETURN
PUSH1 0x2a
PUSH1 0x80
MSTORE
PUSH1 0x20
PUSH1 0x80
RETURN
*/

/*
Smart contract code:

PUSH1 0x2a
PUSH1 0x80
MSTORE
PUSH1 0x20
PUSH1 0x80
RETURN
*/

/*
Link to evm.codes:
https://www.evm.codes/playground?fork=arrowGlacier&unit=Wei&codeType=Mnemonic&code='~2ayMSTOREz~20yRETURN'~PUSH1%200xz%5Cnyz~80z%01yz~_
*/

contract Solve is Script, Test {
  address target = address(0x3aa13Ff247aFb3BAa29b3d528F5Db21AB4Bf984F);
  using stdStorage for StdStorage;

  function run() public {
    vm.startBroadcast();

    bytes memory bytecode = hex"386000600039600a600bf3602a60805260206080f3";
    emit log_bytes(bytecode);

    address deployAddress;
    uint256 codeLength;
    assembly {
      deployAddress := create(0, add(bytecode, 0x20), mload(bytecode))
      codeLength := extcodesize(deployAddress)
    }
    console.log("Address is %s", deployAddress);
    console.log("Code length is %s", codeLength);

    // solhint-disable-next-line avoid-low-level-calls
    (bool success, bytes memory data) = deployAddress.call(abi.encodeWithSignature("whatIsTheMeaningOfLife()"));
    emit log_named_bytes("Returned data", data);

    require(success, "Call failed");
    require(abi.decode(data, (uint256)) == 42, "Wrong return value");

    (bool setSuccess, ) = target.call(abi.encodeWithSignature("setSolver(address)", deployAddress));
    require(setSuccess, "Setting solver failed");

    vm.stopBroadcast();
  }
}
