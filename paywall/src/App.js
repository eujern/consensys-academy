import React, { Component } from 'react'
import Hub from '../build/contracts/Hub.json'
import getWeb3 from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

class App extends Component {
  constructor(props) {
    super(props)

    this.state = {
      storageValue: 0,
      web3: null
    }
  }

  componentWillMount() {
    // Get network provider and web3 instance.
    // See utils/getWeb3 for more info.

    getWeb3
    .then(results => {
      this.setState({
        web3: results.web3
      })

      // Instantiate contract once web3 provided.
      this.instantiateContract()
    })
    .catch(() => {
      console.log('Error finding web3.')
    })
  }

  instantiateContract() {
    const contract = require('truffle-contract')
    const hub = contract(Hub)
    hub.setProvider(this.state.web3.currentProvider)

    // Declaring this for later so we can chain functions on Hub.
    var hubInstance

    // Get accounts.
    this.state.web3.eth.getAccounts((error, accounts) => {
      hub.deployed().then((instance) => {
        hubInstance = instance

        // can't do .paywalls... arrays need to be accessed individually by element
        // e.g. hubInstance.paywalls.call(0) for first element

        // need to use log watchers ...
        // newCampaignWatcher = watchForNewCampaigns();
        // but how will this scale, watching from block 0?????
        // actually... have a function that returns the paywalls.length,
        // then loop over that using .paywalls.call(i) to build the list
/*
function watchForNewCampaigns() {
  hub.LogNewCampaign( {}, {fromBlock: 0})
  .watch(function(err,newCampaign) {
    if(err)
    {
      console.error("Campaign Error:",err);
    } else {
      // normalizing data for output purposes
      console.log("New Campaign", newCampaign);
      newCampaign.args.user   = newCampaign.args.sponsor;
      newCampaign.args.amount = newCampaign.args.goal.toString(10);
      // only if non-repetitive (testRPC)
      if(typeof(txn[newCampaign.transactionHash])=='undefined')
      {
        $scope.campaignLog.push(newCampaign);
        txn[newCampaign.transactionHash]=true;
        upsertCampaign(newCampaign.args.campaign);
      }
    }
  })
*/


        //return hubInstance.paywalls.call()
      })
    })
  }

  render() {
    return (
      <div className="App">
        <nav className="navbar pure-menu pure-menu-horizontal">
            <a href="#" className="pure-menu-heading pure-menu-link">Truffle Box</a>
        </nav>

        <main className="container">
          <div className="pure-g">
            <div className="pure-u-1-1">
              <h1>Good to Go!</h1>
              <p>Your Truffle Box is installed and ready.</p>
              <h2>Smart Contract Example</h2>
              <p>If your contracts compiled and migrated successfully, below will show a stored value of 5 (by default).</p>
              <p>Try changing the value stored on <strong>line 59</strong> of App.js.</p>
            </div>
          </div>
        </main>
      </div>
    );
  }
}

export default App
