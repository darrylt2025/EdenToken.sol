// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract EdenToken is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuard {
    mapping(address => uint256) public lockdownEnd;

    event LockdownCancelled(address indexed user);

    function initialize(string memory name, string memory symbol) initializer public {
        __ERC20_init(name, symbol);
        __Ownable_init();
    }

    function transfer(address to, uint256 amount) public nonReentrant returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function lockAccount(uint256 duration) public nonReentrant returns (bool) {
        require(duration > 0, "Duration must be greater than zero.");

        // Check for potential overflow
        uint256 expiration = block.timestamp + duration;
        require(expiration >= block.timestamp, "Overflow detected!"); 
        require(expiration < type(uint256).max, "Duration is too long."); 

        lockdownEnd[msg.sender] = expiration;
        return true;
    }

    function cancelLockdown(address user) public onlyOwner {
        // Check if the provided address is valid
        require(user != address(0), "Invalid user address");

        delete lockdownEnd[user];

        emit LockdownCancelled(user);
    }
}