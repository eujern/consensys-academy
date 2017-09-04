pragma solidity ^0.4.4;

import './Owned.sol';


contract Stoppable is Owned {
  bool public running;

  event LogStopRunning(address owner);
  event LogStartRunning(address owner);

  modifier isRunning() {
    require(running);
    _;
  }

  function Stoppable() {
    running = true;
  }

  function stopRunning()
    isOwner
  {
    running = false;
    LogStopRunning(msg.sender);
  }

  function startRunning()
    isOwner
  {
    running = true;
    LogStartRunning(msg.sender);
  }
}
