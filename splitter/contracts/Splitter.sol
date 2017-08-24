pragma solidity ^0.4.4;

contract Splitter {
  address public owner;
	address public alice;
  address public bob;
  address public carol;

	function Splitter(address _alice, address _bob, address _carol) payable {
    owner = msg.sender;
		alice = _alice;
    bob = _bob;
    carol = _carol;
	}

  function killMe() {
    require(msg.sender == owner);
    selfdestruct(owner);
  }

  function () payable {
    if (msg.sender == alice) {
      uint half = msg.value / 2;
      bob.transfer(half);
      carol.transfer(half);
    }
  }
}
