pragma solidity ^0.4.24;

import 'github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol';

contract WeWin {
    struct Option {
        bool selected;
        uint fund;
        bool cancel;
    }

    address public creator;
    uint public minimumFund;
    uint public closingTime;
    mapping(uint => address[]) public allVoters;
    mapping(uint => mapping(address => Option)) public allVotes;
    mapping(uint => uint) public funds;
    
    event onVote(address indexed voter, uint indexed option, uint indexed fund);
    event onUnvote(address indexed voter, uint indexed option, uint indexed fund);
    
    modifier onlyCreator {
        require(msg.sender == creator);
        _;
    }
    
    constructor (address _creator, uint _closingTime) public {
        creator = _creator;
        minimumFund = 1e17;
        closingTime = _closingTime;
    }

    function vote(uint _option) payable public {
        require(msg.value == minimumFund);
        require(closingTime >= block.timestamp);
        
        Option storage option = allVotes[_option][msg.sender];
        
        // index voters
        if (!option.selected) {
            option.selected = true;
            allVoters[_option].push(msg.sender);
        } 
        
        if (option.cancel) {
            option.cancel = false;
            option.fund = msg.value;
        } else { 
            option.fund = SafeMath.add(option.fund, msg.value);
        }
        
        funds[_option] = SafeMath.add(funds[_option], msg.value);
        
        emit onVote(msg.sender, _option, msg.value);
    }
    
    function getVotes(uint _option, uint offset, uint limit) view public returns(address[], uint[], bool[]) {
        address[] storage voters = allVoters[_option];
        mapping(address => Option) votes = allVotes[_option];
        
        if (offset < voters.length) {
            uint count = 0;
            uint resultLength = voters.length - offset > limit ? limit : voters.length - offset;
            address[] memory _voters = new address[](resultLength);
            uint[] memory _funds = new uint[](resultLength);
            bool[] memory _cancels = new bool[](resultLength); 
            
            for (uint i = offset; (i < voters.length) && (count < limit); i++) {
                _voters[count] = voters[i];
                _funds[count] = votes[_voters[i]].fund;
                _cancels[count] = votes[voters[i]].cancel;
                count++;
            }

            return(_voters, _funds, _cancels);
        }
    } 
}
