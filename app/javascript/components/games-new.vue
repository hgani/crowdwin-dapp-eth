<template lang="pug">
  div
    h1 New Game
    .card
      .card-body
        game-form(      
          :csrf-token="csrfToken"
          :read-only-game="game"
          :submitting="submitting"
          @submit="submit"
        )
</template>

<script>
import gameContract from "../contract";
import Utils from "../utils";

const ttrOption = {
  closeButton: true,
  positionClass: "toast-bottom-full-width",
  timeOut: 0,
  extendedTimeOut: 0,
  tapToDismiss: false
};

const minimumTime = new Date();
// minimumTime.setDate(minimumTime.getDate() + 1);

export default {
  props: ["csrfToken"],
  data() {
    return {
      game: {
        minimumFund: 0.01,
        minimumTime,
        minimumTimeString: minimumTime.toISOString(), //.split("T")[0],
        closingTime: null,
        options: [null, null],
        minimumOptionsLength: 2
      },
      submitting: false
    };
  },
  methods: {
    submit(game) {
      const self = this;

      const { csrfToken } = self;
      const creator = web3.eth.defaultAccount;
      const Contract = web3.eth.contract(gameContract.ABI);

      Utils.validateGameForm(game, () => {
        const closingTime = parseInt(new Date(game.closingTime) / 1000);

        const data = Contract.new.getData(creator, closingTime, {
          data: gameContract.byteCode
        });

        self.submitting = true;
        web3.eth.estimateGas({ data }, (err, data) => {
          if (err) {
            self.submitting = false;
            throw err;
          }

          Contract.new(
            creator,
            closingTime,
            {
              from: creator,
              gas: data + 1,
              gasPrice: 30 * 1e9,
              data: gameContract.byteCode
            },
            (err, data) => {
              // When creating contract, this callback will be called 2 times.
              // The first time data.address will be undefined
              // The second time data.address will be filled

              if (err) {
                self.submitting = false;
                throw err;
              }

              const link = `<a class="btn btn-primary" href="${
                web3Helper.viewTxPath
              }/${
                data.transactionHash
              }" target="_blank">View Transaction on Etherscan</a>`;

              if (!data.address) {
                ttr.success(`Transaction Success. ${link}`, null, ttrOption);
                $.ajax({
                  url: "/games.json",
                  method: "post",
                  data: {
                    tx_hash: data.transactionHash,
                    creator,
                    label: game.label,
                    options: JSON.stringify(game.options),
                    authenticity_token: csrfToken
                  },
                  success() {
                    self.submitting = false;
                    self.resetGame();
                    ttr.success(
                      "Your contract has been saved",
                      null,
                      ttrOption
                    );
                  },
                  error() {
                    self.submitting = false;
                    ttr.error("Error when saving contract", null, ttrOption);
                  }
                });
              }
            }
          );
        });
      });
    },
    resetGame() {
      const self = this;

      self.game = {
        minimumFund: 0.01,
        closingTime: null,
        options: [null, null],
        minimumOptionsLength: 2
      };
    }
  }
};
</script>
