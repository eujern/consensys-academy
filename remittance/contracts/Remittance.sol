pragma solidity ^0.4.4;

contract Remittance {
  struct Deposit {
    address depositer;
    bytes32 hashedPassword;
    uint256 amount;
    uint expiration;
  }

  address owner;
  uint maxDuration;
  uint commission;  // per transaction
  uint commissionBalance;  // total collected
	mapping (address => Deposit) deposits;

	event LogDeposit(address indexed depositer,
                   address indexed collector,
                   bytes32 hashedPassword,
                   uint amount,
                   uint duration);
  event LogCollect(address indexed collector, uint amount);
  event LogWithdraw(address indexed depositer, uint amount);
  event LogRetrieveCommission(uint amount);

	function Remittance(uint _commission, uint _maxDuration) {
    owner = msg.sender;
    commission = _commission;
    maxDuration = _maxDuration;
	}

  function killMe() {
    // run away with the monies!?
    require(msg.sender == owner);
    selfdestruct(owner);
  }

  function deposit(address collector, bytes32 hashedPassword, uint duration)
    payable
  {
    require(duration <= maxDuration);
    require(msg.value > 0);
    deposits[collector] = Deposit(msg.sender, hashedPassword, msg.value - commission, block.number + duration);
    commissionBalance += commission;
    LogDeposit(msg.sender, collector, hashedPassword, msg.value - commission, duration);
  }

  // redeeming the deposit
  function collect(string password) {
    require(!hasExpired(msg.sender));
    require(deposits[msg.sender].depositer != 0);
    require(hashPassword(password) == deposits[msg.sender].hashedPassword);
    uint256 amount = deposits[msg.sender].amount;
    delete deposits[msg.sender];
    msg.sender.transfer(amount);
    LogCollect(msg.sender, amount);
  }

  // canceling the deposit
  function withdraw(address collector) {
    require(hasExpired(collector));
    uint amount = deposits[collector].amount;
    address depositer = deposits[collector].depositer;
    require(msg.sender == depositer);
    delete deposits[collector];
    msg.sender.transfer(amount);
    LogWithdraw(depositer, amount);
  }

  function retrieveCommissions() {
    require(msg.sender == owner);
    uint amount = commissionBalance;
    commissionBalance = 0;
    msg.sender.transfer(amount);
    LogRetrieveCommission(amount);
  }

  function hashPassword(string password) constant returns(bytes32 hashedPassword) {
    return keccak256(password);
  }

  function hasExpired(address collector) constant returns(bool expired){
    if (deposits[collector].depositer == 0) {
      return false;
    }
    return block.number > deposits[collector].expiration;
  }
}
