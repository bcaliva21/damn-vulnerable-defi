// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Attack {}

// who should be the borrower? attacker or attackContract?

// what if we do a call where borrower is the flashLoan pool itself? 

// what if target is damnValuableToken?
    // on one call to flashLoan we can call approve but as the pool
        // dvt.increaseAllowance(address spender = attacker.address, uint256 amount = 1000000)
        // then we call dvt.transferFrom(address sender = pool.address, address recipient = attacker.address, uint256 amount = 1000000) 


// call flashLoan
    // borrowAmount = 1 MIL
    // borrower = attacker
    // target = attackContract
    // data = function in attack to target
    // define balanceBefore = dvt.balanceOf(pool)
    // require balanceBefore gte borrowAmount
    // dvt.transfer borrowAmount from pool to borrower
        // _balances[pool] -= borrowAmount
        // _balances[attacker] += borrowAmount
    // target.call(data) _we can control of the flow here_
        // ???

    // define balanceAfter = dvt.balanceOf(pool)
    // require balanceAfter gte balanceBefore

// can we abuse address(this) in any meaningful way?

// can we subvert the require statements in anyway?

// can we manipulate the variables balanceBefore or balanceAfter in anyway?
    // anyway we could make balanceBefore eq 0???

// what can we do when we gain control @ target.call to drain the funds?
