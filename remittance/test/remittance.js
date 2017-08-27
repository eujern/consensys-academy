var Remittance = artifacts.require("./Remittance.sol");

contract('Remittance', function(accounts) {
  var alice = accounts[0];
  // var bob = accounts[1];
  var carol = accounts[1];

  var bobPassword = '123';

  it("should make a successful deposit and a successful collection", function() {
    var commission = 1000;
    var maxDuration = 1;

    Remittance.new(commission, maxDuration).then(instance => {
      instance.hashPassword(bobPassword).then(hashedPassword => {
        var amount = 100000;

        instance.deposit(carol, hashedPassword, maxDuration, {from: alice, value: amount}).then(txObj => {
          instance.collect(bobPassword, {from: carol}).then(txObj => {
            console.log(txObj);
          });
        });
      });
    });
  });

  it("should make a successful deposit and a failed collection due to wrong password", function() {
    var commission = 1000;
    var maxDuration = 1;

    Remittance.new(commission, maxDuration).then(instance => {
      instance.hashPassword(bobPassword).then(hashedPassword => {
        var amount = 100000;

        instance.deposit(carol, hashedPassword, maxDuration, {from: alice, value: amount}).then(txObj => {
          instance.collect('wrongpassword', {from: carol})
          .then(txObj => {
            assert(false, "testThrow was supposed to throw but didn't.");
          }).catch(error => {
          });
        });
      });
    });
  });

  it("should make two successful deposit and a failed collection due to expiration, then a successful withdraw", function() {
    var commission = 1000;
    var maxDuration = 1;

    Remittance.new(commission, maxDuration, {from: alice}).then(instance => {
      instance.hashPassword(bobPassword).then(hashedPassword => {
        var amount = 100000;

        instance.deposit(carol, hashedPassword, maxDuration, {from: alice, value: amount}).then(txObj => {
          instance.deposit(alice, hashedPassword, maxDuration, {from: carol, value: amount}).then(txObj => {
            instance.collect(bobPassword, {from: carol, to: instance.contract.address}).then(txObj => {
              assert(false, "testThrow was supposed to throw but didn't.");
            }).catch(error => {

              instance.withdraw(carol, {from: alice}).then(txObj => {

              })

              instance.retrieveCommissions({from: alice}).then(txObj => {

              })

            });

          });
        });
      });
    });
  });



});
