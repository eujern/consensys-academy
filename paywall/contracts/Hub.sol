pragma solidity ^0.4.4;

import "./Paywall.sol";

contract Hub is Stoppable {
  uint public avgBlockTime;

  address[] public paywalls;
  mapping(address => bool) paywallExists;

  modifier onlyIfPaywall(address paywall) {
    require(paywallExists[paywall]);
    _;
  }

  event LogUpdateAvgBlockTime(address sender, uint _avgBlockTime);
  event LogCreatePaywall(address provider, address paywall, uint _avgBlockTime, uint weiPerMonth);
  event LogPaywallStopped(address sender, address paywall);
  event LogPaywallStarted(address sender, address paywall);
  event LogPaywallNewOwner(address sender, address paywall, address newOwner);

  function Hub(uint _avgBlockTime) {
    avgBlockTime = _avgBlockTime;
    paywalls.length = 0;
  }

  function updateAvgBlockTime(uint _avgBlockTime)
    isRunning
    isOwner
  {
    avgBlockTime = _avgBlockTime;
    LogUpdateAvgBlockTime(msg.sender, avgBlockTime);
  }

  function getPaywallCount()
    public
    constant
    returns(uint paywallCount)
  {
    return paywalls.length;
  }

  function createPaywall(uint weiPerMonth)
    public
    returns(address paywallContract)
  {
    Paywall trustedPaywall = new Paywall(msg.sender, avgBlockTime, weiPerMonth);
    paywalls.push(trustedPaywall);
    paywallExists[trustedPaywall] = true;
    LogCreatePaywall(msg.sender, trustedPaywall, avgBlockTime, weiPerMonth);
    return trustedPaywall;
  }

  // Pass-through Admin Controls

  function stopPaywall(address paywall)
    isOwner
    onlyIfPaywall(paywall)
  {
    Paywall trustedPaywall = Paywall(paywall);
    trustedPaywall.stopRunning();
    LogPaywallStopped(msg.sender, paywall);
  }

  function startPaywall(address paywall)
    isOwner
    onlyIfPaywall(paywall)
  {
    Paywall trustedPaywall = Paywall(paywall);
    trustedPaywall.startRunning();
    LogPaywallStarted(msg.sender, paywall);
  }

  function changePaywallOwner(address paywall, address newOwner)
    isOwner
    onlyIfPaywall(paywall)
  {
    Paywall trustedPaywall = Paywall(paywall);
    trustedPaywall.changeOwner(newOwner);
    LogPaywallNewOwner(msg.sender, paywall, newOwner);
  }
}
