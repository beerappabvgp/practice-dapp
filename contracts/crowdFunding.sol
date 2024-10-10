// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract CrowdFunding {

    event CampaignCreated(uint256 indexed campaignId, address indexed creator, uint256 goal, uint256 deadline);
    event SuccessfulPledge(uint256 indexed CampignId, address indexed pledger, uint256 amount);
    event WithDrawSuccessful(uint256 indexed campaignId, uint256 amount);
    event RefundSuccessful(uint256 indexed campaignId, address indexed receiver, uint256 amount);

    error UnAuthorized();
    error GoalNotReached(uint256 target, uint256 pledged);

    modifier onlyCreator(uint256 _campaignId) {
        if (msg.sender != campaigns[_campaignId].creator) {
            revert UnAuthorized();
        }
        _;
    }

    struct Campaign {
        address payable creator;
        uint256 goal;
        uint256 pledged;
        uint256 deadline;
        bool withdrawn;
        mapping(address => uint256) pledges;
    }

    // we can have many campaigns right 
    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner has the right to invoke the function.");
        _;
    }

    // create campaigns
    function createCampaign(uint256 _goal, uint256 duration) external {
        require(_goal > 0 , "Goal must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        campaignCount++;
        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.creator = payable(msg.sender);
        newCampaign.deadline = block.timestamp + duration;
        newCampaign.pledged = 0;
        newCampaign.goal = _goal;
        newCampaign.withdrawn = false;
        emit CampaignCreated(campaignCount, msg.sender, _goal, newCampaign.deadline);
    }

    // function to pledge ether to a campaign
    function pledge(uint256 _campaignId) external payable {
        // get the campaign
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp <= campaign.deadline, "Deadline has been reached, campaign has been ended.");
        require(msg.value > 0, "Amount must be greater than 0");
        campaign.pledged += msg.value;
        // we need to add pledger to the pledger mapping 
        campaign.pledges[msg.sender] += msg.value;
        emit SuccessfulPledge(_campaignId, msg.sender, msg.value);
    }

    // campaign creator can withdraw the funds 
    function withdraw(uint256 _campaignId) external onlyCreator(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp > campaign.deadline, "Campaign has not ended yet");
        if (campaign.pledged < campaign.goal) {
            revert GoalNotReached(campaign.pledged, campaign.goal);
        }
        require(!campaign.withdrawn, "Funds already withdrawn");

        uint256 amount = campaign.pledged;
        campaign.withdrawn = true;

        (bool success, ) = campaign.creator.call{value: amount}("");
        require(success, "Withdrawal failed");
        emit WithDrawSuccessful(_campaignId, amount);
    }

    // function to refund ether if the target is not met 
    function refund(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        // first check whether the campaign has ended or not 
        require(block.timestamp > campaign.deadline, "Still the campaign has not been ended");
        require(campaign.goal > campaign.pledged, "Target has been achieved you cannot withdraw funds");
        uint256 amount = campaign.pledges[msg.sender];
        require(amount > 0 , "Pledged amount should be greater than O.");
        campaign.pledges[msg.sender] = 0;
        address payable receiver = payable(msg.sender);
        (bool success, ) = receiver.call{value: amount}("");
        require(success, "Refund failed");
        emit RefundSuccessful(_campaignId, msg.sender, amount);
    }

    // function to get the remaining time of the campaign
    function timeLeft(uint256 _campaignId) external view returns(uint) {
        Campaign storage campaign = campaigns[_campaignId];
        uint256 currentTime = block.timestamp;
        return campaign.deadline - currentTime;
    }

    function getContractBalance() external view returns(uint256) {
        return address(this).balance;
    }
}