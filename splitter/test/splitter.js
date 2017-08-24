var Splitter = artifacts.require("./Splitter.sol");

contract('Splitter', function(accounts) {
  var owner = accounts[0]
  var alice = accounts[1];
  var bob = accounts[2];
  var carol = accounts[3];

  var instance;
  var contractAddress;

  beforeEach("deploy and prepare", function() {
    return Splitter.new(alice, bob, carol).then(_instance => {
      instance = _instance;
      return instance.address;
    }).then(address => contractAddress = address);
  });

  it("should initialize addresses", function() {
    instance.owner.call().then(address => {
      assert.equal(address, owner, "Owner's address was not initialized correctly");
      return instance.alice.call();
    }).then(address => {
      assert.equal(address, alice, "Alice's address was not initialized correctly");
      return instance.bob.call();
    }).then(address => {
      assert.equal(address, bob, "Bob's address was not initialized correctly");
      return instance.carol.call();
    }).then(address => {
      assert.equal(address, carol, "Carol's address was not initialized correctly");
      return instance.owner.call();
    });
  });

  for (var i of [0, 1, 5, 10]) {
    it(`should split ${i} wei from Alice to Bob and Carol`, function() {
      testSendingFromAlice(i);
    });
  }

  for (var i of [0, 1, 5, 10]) {
    it(`should put ${i} wei from Bob into contract account`, function() {
      testSendingFromBob(i);
    });
  }

  function testSendingFromAlice(amount) {
    var originalContractBalance;
    var originalAliceBalance;
    var originalBobBalance;
    var originalCarolBalance;

    var remainder = amount % 2;
    var splitAmount = amount - remainder;

    web3.eth.getBalance(contractAddress, (_, balance) => {
      originalContractBalance = balance;

      web3.eth.getBalance(alice, (_, balance) => {
        originalAliceBalance = balance;

        web3.eth.getBalance(bob, (_, balance) => {
          originalBobBalance = balance;

          web3.eth.getBalance(carol, (_, balance) => {
            originalCarolBalance = balance;

            web3.eth.sendTransaction({
              from: alice,
              to: contractAddress,
              value: amount,
            }, (_, txHash) => {
              var gasUsed;
              web3.eth.getTransactionReceipt(txHash, (_, tx) => {
                gasUsed = tx.gasUsed;

                web3.eth.getBalance(contractAddress, (_, balance) => {
                  assert.isTrue(balance.equals(originalContractBalance.plus(remainder)));
                });

                web3.eth.getBalance(alice, (_, balance) => {
                  assert.isTrue(balance.equals(originalAliceBalance.minus(amount).minus(gasUsed)));
                });

                web3.eth.getBalance(bob, (_, balance) => {
                  assert.isTrue(balance.equals(originalBobBalance.plus(splitAmount / 2)));
                });

                web3.eth.getBalance(carol, (_, balance) => {
                  assert.isTrue(balance.equals(originalCarolBalance.plus(splitAmount / 2)));
                });
              });

            });
          });
        });
      });
    });
  }

  function testSendingFromBob(amount) {
    var originalContractBalance;
    var originalAliceBalance;
    var originalBobBalance;
    var originalCarolBalance;

    web3.eth.getBalance(contractAddress, (_, balance) => {
      originalContractBalance = balance;

      web3.eth.getBalance(alice, (_, balance) => {
        originalAliceBalance = balance;

        web3.eth.getBalance(bob, (_, balance) => {
          originalBobBalance = balance;

          web3.eth.getBalance(carol, (_, balance) => {
            originalCarolBalance = balance;

            web3.eth.sendTransaction({
              from: bob,
              to: contractAddress,
              value: amount,
            }, (_, txHash) => {
              var gasUsed;
              web3.eth.getTransactionReceipt(txHash, (_, tx) => {
                gasUsed = tx.gasUsed;

                web3.eth.getBalance(contractAddress, (_, balance) => {
                  assert.isTrue(balance.equals(originalContractBalance.plus(amount)));
                });

                web3.eth.getBalance(alice, (_, balance) => {
                  assert.isTrue(balance.equals(originalAliceBalance));
                });

                web3.eth.getBalance(bob, (_, balance) => {
                  assert.isTrue(balance.equals(originalBobBalance.minus(amount).minus(gasUsed)));
                });

                web3.eth.getBalance(carol, (_, balance) => {
                  assert.isTrue(balance.equals(originalCarolBalance));
                });
              });

            });
          });
        });
      });
    });
  }

});
