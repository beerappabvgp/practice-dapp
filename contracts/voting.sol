// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DecentralizedVoting {
    struct Candidate {
        string name;
        uint256 votes;
    }

    struct Election {
        address creator;
        string title;
        string description;
        Candidate[] candidates;
        bool isActive;
        mapping(address => bool) hasVoted;
    }

    // List of all elections
    Election[] public elections;

    // Events to log important actions
    event ElectionCreated(uint256 indexed electionId, string title, string description, address indexed creator);
    event Voted(uint256 indexed electionId, address indexed voter, string candidate);
    event ElectionClosed(uint256 indexed electionId, string winner);

    // Custom errors for gas efficiency
    error ElectionNotActive();
    error AlreadyVoted();
    error Unauthorized();

    // Modifier to check if election is active
    modifier onlyActive(uint256 _electionId) {
        if (!elections[_electionId].isActive) {
            revert ElectionNotActive();
        }
        _;
    }

    // Modifier to ensure the election creator is the caller
    modifier onlyCreator(uint256 _electionId) {
        if (msg.sender != elections[_electionId].creator) {
            revert Unauthorized();
        }
        _;
    }

    // Function to create a new election
    function createElection(
        string memory _title,
        string memory _description,
        string[] memory _candidateNames
    ) external {
        require(bytes(_title).length > 0, "Title is required");
        require(bytes(_description).length > 0, "Description is required");
        require(_candidateNames.length > 0, "At least one candidate required");

        Election storage newElection = elections.push();
        newElection.creator = msg.sender;
        newElection.title = _title;
        newElection.description = _description;
        newElection.isActive = true;

        // Add candidates to the election
        for (uint256 i = 0; i < _candidateNames.length; i++) {
            newElection.candidates.push(Candidate({name: _candidateNames[i], votes: 0}));
        }

        emit ElectionCreated(elections.length - 1, _title, _description, msg.sender);
    }

    // Function to vote for a candidate in an election
    function vote(uint256 _electionId, uint256 _candidateIndex) external onlyActive(_electionId) {
        Election storage election = elections[_electionId];
        require(_candidateIndex < election.candidates.length, "Invalid candidate index");
        if (election.hasVoted[msg.sender]) {
            revert AlreadyVoted();
        }

        election.hasVoted[msg.sender] = true;
        election.candidates[_candidateIndex].votes++;

        emit Voted(_electionId, msg.sender, election.candidates[_candidateIndex].name);
    }

    // Function to close the election and declare the winner
    function closeElection(uint256 _electionId) external onlyCreator(_electionId) onlyActive(_electionId) {
        Election storage election = elections[_electionId];

        // Find the candidate with the highest votes
        uint256 maxVotes = 0;
        string memory winner;

        for (uint256 i = 0; i < election.candidates.length; i++) {
            if (election.candidates[i].votes > maxVotes) {
                maxVotes = election.candidates[i].votes;
                winner = election.candidates[i].name;
            }
        }

        election.isActive = false;

        emit ElectionClosed(_electionId, winner);
    }

    // Function to get the number of candidates in an election
    function getCandidateCount(uint256 _electionId) external view returns (uint256) {
        return elections[_electionId].candidates.length;
    }

    // Function to get a candidate's details by index
    function getCandidate(uint256 _electionId, uint256 _candidateIndex) external view returns (string memory name, uint256 votes) {
        Candidate storage candidate = elections[_electionId].candidates[_candidateIndex];
        return (candidate.name, candidate.votes);
    }

    // Function to check if an election is active
    function isElectionActive(uint256 _electionId) external view returns (bool) {
        return elections[_electionId].isActive;
    }
}
