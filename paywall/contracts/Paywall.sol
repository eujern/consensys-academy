pragma solidity ^0.4.4;

import './Stoppable.sol';


contract Paywall is Stoppable {
  uint constant SECONDS_IN_MONTH = 60 * 60 * 24 * 30;

  address public contentProvider;
  uint blocksPerMonth;
  uint public weiPerMonth;
  mapping(address => uint) public expirations;

  event LogUpdateAvgBlockTime(address sender, uint avgBlockTime, uint _blocksPerMonth);
  event LogUpdatePrice(address sender, uint _weiPerMonth);
  event LogPay(address consumer, uint months);

	function Paywall(address _contentProvider, uint avgBlockTime, uint _weiPerMonth) {
    contentProvider = _contentProvider;
    blocksPerMonth = SECONDS_IN_MONTH / avgBlockTime;
    weiPerMonth = _weiPerMonth;
	}

  function updateAvgBlockTime(uint newAvg)
    isRunning
    isOwner
  {
    blocksPerMonth = SECONDS_IN_MONTH / newAvg;
    LogUpdateAvgBlockTime(msg.sender, newAvg, blocksPerMonth);
  }

  function updatePrice(uint _weiPerMonth)
    isRunning
  {
    require(msg.sender == contentProvider);
    weiPerMonth = _weiPerMonth;
    LogUpdatePrice(msg.sender, weiPerMonth);
  }

  function pay(uint months)
    isRunning
    payable
  {
    require(months * weiPerMonth == msg.value);
    if (expirations[msg.sender] == 0) {
      expirations[msg.sender] = block.number + months * blocksPerMonth;
    } else {
      expirations[msg.sender] += months * blocksPerMonth;
    }
    LogPay(msg.sender, months);
  }

  function canAccess()
    isRunning
    constant
    returns(bool)
  {
    return block.number < expirations[msg.sender];
  }
}
