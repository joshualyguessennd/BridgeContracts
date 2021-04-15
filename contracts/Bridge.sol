//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "OpenZeppelin/openzeppelin-contracts@4.0.0/contracts/token/ERC20/IERC20.sol";
import "./InterfaceToken.sol";

contract Bridge {
    IToken public token;
    mapping(address => mapping(uint => bool)) public processedNonces;

    enum State{Mint, Burn}

    event Transfer(
        address from,
        address to,
        uint amount,
        uint date,
        uint nonce,
        bytes signature,
        State indexed state
    );

    constructor(address _token){
        token = IToken(_token);
    }


    function burn(address to, uint amount, uint nonce, bytes calldata signature) public {
        require(processedNonces[msg.sender][nonce] == false, "transfer already processed");
        processedNonces[msg.sender][nonce] = true;
        token.burn(msg.sender, amount);

        emit Transfer(
            msg.sender,
            to,
            amount,
            block.timestamp,
            nonce,
            signature,
            State.Burn
        );
    }

    function mint(address from, address to, uint amount, uint nonce, bytes calldata signature) external {
        bytes32 message = prefixed(keccak256(abi.encodePacked(from, to, amount, nonce)));
        require(recoverSigner(message, signature) == from, "wrong signature");
        require(processedNonces[msg.sender][nonce] == false, "transfer already processed");
        token.mint(to, amount);

        emit Transfer(
            msg.sender,
            to,
            amount,
            block.timestamp,
            nonce,
            signature,
            State.Mint
        );
    }

    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) =  splitSignature(sig);

        return ecrecover(message, v, r, s);
    }

    function splitSignature(bytes memory sig) internal pure returns(uint8, bytes32, bytes32) {
        require(sig.length == 65);
        uint8 v;
        bytes32 r;
        bytes32 s;

        assembly {
            r:= mload(add(sig, 32))
            
            s:= mload(add(sig, 64))

            v:= byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }


    function prefixed(bytes32 hash) internal pure returns(bytes32) {
        return keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n32', hash));
    }

}