// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract DecentralizedDonation {
    // anyone can send ether to the contract 
    // only owner of the contract can withdraw the funds right 
    // track donations

    struct Donation {
        uint256 amount;
        uint256 timestamp;
    }

    mapping(address => Donation) public donations;

    address public owner;
    event DonationReceived(address indexed donor, uint256 amount, uint256 timestamp);

    event FundsWithdrawn(address indexed by, uint amount);

    error Unauthorized();

    error InsufficientFunds(uint requested, uint available);

    // constructor to store the owner of the contract 

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    // payable will accept ether 
    function donate() external payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        donations[msg.sender] = Donation({
            amount: msg.value,
            timestamp: block.timestamp
        });

        // emitting the donation received event 
        emit DonationReceived(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) {
            revert InsufficientFunds(0, balance);
        }
        // transfer the funds to the owner 
        (bool success, ) = owner.call{value: balance}("");
        require(success, "Withdrawl Failed");
        emit FundsWithdrawn(owner, balance);
    }

    function getContractBalance() external view returns(uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

}