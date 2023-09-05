// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseCCIPSender} from "./BaseCCIPSender.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CCIPERC20 is ERC721, BaseCCIPSender {
    uint256 tokenCount;

    constructor(
        address _router
    ) BaseCCIPSender(_router) ERC721("CCIP_Demo", "CCIPD") {}

    function mint(address _to) external {
        _mint(_to, ++tokenCount);
    }

    function send(
        uint64 destinationChainSelector,
        address receiver,
        string calldata message,
        address token,
        uint256 amount
    ) public {
        Client.EVMTokenAmount[] memory tokens = new Client.EVMTokenAmount[](1);
        tokens[0] = Client.EVMTokenAmount({token: token, amount: amount});

        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: abi.encode(message), // ABI-encoded string message
            tokenAmounts: tokens, // Tokens amounts
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(0) // Setting feeToken to zero address, indicating native asset will be used for fees
        });
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public pure override(ERC721, BaseCCIPSender) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
