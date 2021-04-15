//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './Bridge.sol';

contract BridgeXDaiChain is Bridge {
  constructor(address token) Bridge(token) {}
}