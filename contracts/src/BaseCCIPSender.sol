// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title BaseCCIPSender
 * @author benhooper.eth
 * @notice A base class intended to be used and extended by specific ERC standards to
 *         utilise CCIP functionality.
 */
contract BaseCCIPSender is CCIPReceiver {
    IRouterClient router;

    constructor(address _router) CCIPReceiver(_router) {
        router = IRouterClient(_router);
    }

    function tester() public pure returns (address) {
        return address(69);
    }

    function _ccipReceive(
        Client.Any2EVMMessage memory message
    ) internal virtual override {
        // modify the state here
    }

    // allows for communication of arbitrary data (to be overriden in inehirting contracts)
    function sendMessage(
        uint64 destinationChainSelector,
        address receiver,
        string calldata message,
        address token,
        uint256 amount
    ) external returns (bytes32 messageId) {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: token,
            amount: amount
        });

        tokenAmounts[0] = tokenAmount;
        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver), // ABI-encoded receiver address
            data: abi.encode(message), // ABI-encoded string message
            tokenAmounts: tokenAmounts, // Tokens amounts
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200_000, strict: false}) // Additional arguments, setting gas limit and non-strict sequency mode
            ),
            feeToken: address(0) // Setting feeToken to zero address, indicating native asset will be used for fees
        });

        IERC20(token).approve(address(router), amount);

        // Get the fee required to send the message
        uint256 fees = router.getFee(destinationChainSelector, evm2AnyMessage);

        // Send the message through the router and store the returned message ID
        messageId = router.ccipSend{value: fees}(
            destinationChainSelector,
            evm2AnyMessage
        );
    }

    /**
     * Helper function used estimate the cost of this transaction
     * @param _destinationChain The destination chain to send this message
     * @param _message The message to be relayed by the chain
     */
    function estimateCCIPFees(
        uint64 _destinationChain,
        Client.EVM2AnyMessage calldata _message
    ) external view returns (uint256) {
        return router.getFee(_destinationChain, _message);
    }

    /// @notice IERC165 supports an interfaceId
    /// @param interfaceId The interfaceId to check
    /// @return true if the interfaceId is supported
    function supportsInterface(
        bytes4 interfaceId
    ) public pure virtual override returns (bool) {
        return
            interfaceId == type(IAny2EVMMessageReceiver).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
}
