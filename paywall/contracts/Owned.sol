pragma solidity ^0.4.4;


contract Owned {
  address public owner;

  event LogChangeOwner(address sender, address newOwner);

  modifier isOwner() {
    require(msg.sender == owner);
    _;
  }

  function Owned() {
    owner = msg.sender;
  }

  function changeOwner(address newOwner)
    isOwner
  {
    owner = newOwner;
    LogChangeOwner(msg.sender, newOwner);
  }
}
