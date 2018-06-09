<template lang='pug'>
  div
    h1 Games
    div(v-for="(game, index) in games")
      game( 
        :game="game"
      )
</template>

<script>
import Vue from "vue/dist/vue.esm";
import gameContract from "../contract";

const ttrOption = {
  closeButton: true,
  positionClass: "toast-bottom-full-width",
  timeOut: 0,
  extendedTimeOut: 0,
  tapToDismiss: false
};

export default {
  data() {
    return {
      games: []
    };
  },
  created() {
    const self = this;

    const Contract = web3.eth.contract(gameContract.ABI);

    $.ajax({
      url: "games.json",
      success(data) {
        for (const game of data.games) {
          game.balance = null;
          game.closingTime = null;
          game.minimumFund = null;
          game.options = JSON.parse(game.options);
          game.optionVotes = [];
          game.optionFunds = [];
          game.addressUrl = `${web3Helper.viewAddressPath}/${game.address}`;
          game.creatorUrl = `${web3Helper.viewAddressPath}/${game.creator}`;
          game.txUrl = `${web3Helper.viewTxPath}/${game.tx_hash}`;
          game.currentUserCreator =
            web3.eth.defaultAccount &&
            web3.eth.defaultAccount.toLowerCase() ===
              game.creator.toLowerCase();

          const contract = Contract.at(game.address);

          (function(game, contract) {
            web3.eth.getBalance(game.address, (err, data) => {
              if (err) throw err;

              game.balance = parseInt(data);
            });

            contract.closingTime.call((err, data) => {
              if (err) throw err;

              game.closingTime = new Date(parseInt(data) * 1000);
            });

            contract.minimumFund.call((err, data) => {
              if (err) throw err;

              game.minimumFund = parseInt(data);
            });

            for (const key in game.options) {
              (function(key) {
                contract.funds.call(key, (err, data) => {
                  if (err) throw err;

                  game.optionFunds.splice(key, 1, parseInt(data));
                });
              })(key);
            }
          })(game, contract); // save params inside closure
        }

        self.games = data.games;
        self.getOptionVotes();
      },
      error() {}
    });
  },
  methods: {
    getOptionVotes() {
      const self = this;

      const Contract = web3.eth.contract(gameContract.ABI);

      for (const game of self.games) {
        const contract = Contract.at(game.address);

        // for each game options
        for (const index in game.options) {
          (function(game, index) {
            // get votes of option
            contract.getVotes.call(index, 0, 1000, (err, data) => {
              const votes = [];
              let isCurrentUser = false;

              votes.currentUserFund = 0;

              // for each votes
              for (let i = 0; i < data[0].length; i++) {
                const value = {};

                value.voter = data[0][i];
                value.fund = parseInt(data[1][i]);

                isCurrentUser =
                  web3.eth.defaultAccount &&
                  web3.eth.defaultAccount.toLowerCase() ===
                    value.voter.toLowerCase();

                if (isCurrentUser) {
                  votes.currentUserFund = value.fund;
                }

                votes.push(value);
              }

              Vue.set(game.optionVotes, index, votes);
            });
          })(game, index);
        }
      }
    }
  }
};
</script>
