//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import './Bridge.sol';

contract BridgeBsc is BridgeBase {
  constructor(address token) BridgeBase(token) {}
}