pragma solidity ^0.4.24;

import "github.com/OpenZeppelin/zeppelin-solidity/contracts/math/SafeMath.sol";

contract WeWin {
  struct Option {
    bool selected;
    uint fund;
    bool cancel;
  }

  address public creator;
  uint public minimumFund;
  uint public closingTime;
  bool public released;
  mapping(uint => address[]) public allVoters;
  mapping(uint => mapping(address => Option)) public allVotes;
  mapping(uint => uint) public funds;
  mapping(address => uint) public availableFunds;
  address[] public winners;

  event onVote(address indexed voter, uint indexed option, uint indexed fund);
  event onUnvote(address indexed voter, uint indexed option, uint indexed fund);

  modifier onlyCreator {
    require(msg.sender == creator);
    _;
  }

  constructor (address _creator, uint _closingTime) public {
    creator = _creator;
    minimumFund = 0.1 ether;
    closingTime = _closingTime;
    released = false;
  }

  function calculatePrices() public onlyCreator {
    require(closingTime < block.timestamp);

    uint i;
    uint _totalFunds = 0;
    uint[] memory _optionVotersCount = new uint[](2);
    for(i = 0; i < 2; i++) {
      _optionVotersCount[i] = allVoters[i].length;
      _totalFunds = SafeMath.add(_totalFunds, funds[i]);
    }

    uint _winnerIndex;
    uint _winnerFunds;
    if (_optionVotersCount[0] > _optionVotersCount[1]) {
      _winnerIndex = 0;
      _winnerFunds = SafeMath.div(_totalFunds, allVoters[_winnerIndex].length);
      _setAvailableFunds(_winnerIndex, _winnerFunds);
    }
    else {
      if (_optionVotersCount[0] < _optionVotersCount[1]) {
        _winnerIndex = 1;
        _winnerFunds = SafeMath.div(_totalFunds, allVoters[_winnerIndex].length);
        _setAvailableFunds(_winnerIndex, _winnerFunds);
      }
      else {
        // Draw condition, set availableFunds with minimumFunds
        for(i = 0; i < 2; i++) {
          _setAvailableFunds(i, minimumFund);
        }
      }
    }

    released = true;
  }

  function _setAvailableFunds(uint _winnerIndex, uint _winnderFunds) private {
    for(uint i = 0; i < allVoters[_winnerIndex].length; i++) {
      address _voterAddress = allVoters[_winnerIndex][i];
      winners.push(_voterAddress);
      availableFunds[_voterAddress] = SafeMath.add(availableFunds[_voterAddress], _winnderFunds);
    }
  }

  function withdraw() public {
    require(closingTime < block.timestamp);
    require(availableFunds[msg.sender] > 0);

    uint _amount = availableFunds[msg.sender];
    availableFunds[msg.sender] = 0;
    msg.sender.transfer(_amount);
  }

  function getWinners() public view returns (address[]) {
    return winners;
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
