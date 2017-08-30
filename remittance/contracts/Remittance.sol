pragma solidity ^0.4.4;

contract Owned {
  address owner;

  function Owned() {
    owner = msg.sender;
  }
}

contract Remittance is Owned {
  struct Deposit {
    address depositer;
    bytes32 hashedPassword;
    uint256 amount;
    uint expiration;
  }

  uint maxDuration;
  uint commission;  // per transaction
  uint commissionBalance;  // total collected
	mapping (bytes32 => Deposit) deposits;

	event LogDeposit(address indexed depositer,
                   bytes32 indexed hashedCollector,
                   bytes32 hashedPassword,
                   uint amount,
                   uint duration);
  event LogCollect(address indexed collector, uint amount);
  event LogWithdraw(address indexed depositer, uint amount);
  event LogRetrieveCommission(uint amount);

	function Remittance(uint _commission, uint _maxDuration) {
    commission = _commission;
    maxDuration = _maxDuration;
	}

  function killMe() {
    // run away with the monies!?
    require(msg.sender == owner);
    selfdestruct(owner);
  }

  function deposit(bytes32 hashedCollector, bytes32 hashedPassword, uint duration)
    payable
  {
    require(duration <= maxDuration);
    require(msg.value > 0);
    require(msg.value > commission);
    deposits[hashedCollector] = Deposit({
      depositer: msg.sender,
      hashedPassword: hashedPassword,
      amount: msg.value - commission,
      expiration: block.number + duration
    });
    commissionBalance += commission;
    LogDeposit(msg.sender, hashedCollector, hashedPassword, msg.value - commission, duration);
  }

  // redeeming the deposit
  function collect(string password) {
    bytes32 hashedCollector = hash(msg.sender);
    require(!hasExpired(hashedCollector));
    require(deposits[hashedCollector].depositer != 0);
    require(hash(password) == deposits[hashedCollector].hashedPassword);
    uint256 amount = deposits[hashedCollector].amount;
    delete deposits[hashedCollector];
    msg.sender.transfer(amount);
    LogCollect(msg.sender, amount);
  }

  // canceling the deposit
  function withdraw(address collector) {
    hashedCollector = hash(collector);
    require(hasExpired(hashedCollector));
    uint amount = deposits[hashedCollector].amount;
    address depositer = deposits[hashedCollector].depositer;
    require(msg.sender == depositer);
    delete deposits[hashedCollector];
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

  function hash(string password) constant returns(bytes32 hashedPassword) {
    return keccak256(password);
  }

  function hasExpired(address hashedCollector) constant returns(bool expired){
    return block.number > deposits[hashedCollector].expiration;
  }
}
