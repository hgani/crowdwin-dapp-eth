<template lang="pug">
  .card.mb-3
    .card-header
      div.d-flex.flex-row.justify-content-between
        h4
          router-link(:to="`/games/${game.address}`" class="d-block") {{game.label}}    
      div(v-if="showInfo")
        strong= 'Address: '
        i
          a(:href='game.addressUrl') {{game.address}}
        br
        strong= 'Creator: '
        i
          a(:href='game.creatorUrl') {{game.creator}}
        = ' '
        span.badge.badge-info {{game.currentUserCreator ? 'you' : ''}}
        br
        strong= 'Tx (deployed): '
        i
          a(:href='game.txUrl') {{game.tx_hash}}
      div.text-right
        small
          a(href="" @click.prevent="toggleInfo") {{ showInfo ? 'Hide Info' : 'Show Info' }}           
    .card-body(v-if="game.currentUserCreator")
      p
        strong Balance: &nbsp;
        | {{game.balance / 1e18}} ETH
        br
        strong Minimum Fund: &nbsp;
        | {{game.minimumFund / 1e18}} ETH
    .card-footer.bg-white
        p
          | Closing Time: {{game.closingTime ? game.closingTime.toLocaleString() : '-'}}
        strong Options
        div.my-3.py-2.px-1.bg-light(
          v-for='(option, index) in game.options'
        )
          .d-flex.flex-row.justify-content-between
            .d-inline-block {{option}} ({{game.optionFunds[index] / 1e18}} ETH)
            .d-inline-block
              button.btn.btn-primary.mr-1(
                v-if="!game.currentUserCreator"
                @click='vote(index)'
                :disabled="submitting"
              ) Vote
          .mt-1(v-if="game.optionVotes[index] && game.optionVotes[index].currentUserFund")
            | You've voted {{game.optionVotes[index].currentUserFund / 1e18}} ETH
</template>

<script>
import gameContract from "../contract";

const ttrOption = {
  closeButton: true,
  positionClass: "toast-bottom-full-width",
  timeOut: 0,
  extendedTimeOut: 0,
  tapToDismiss: false
};

export default {
  props: ["game"],
  data() {
    return {
      showInfo: false,
      submitting: false
    };
  },
  methods: {
    toggleInfo() {
      const self = this;

      self.showInfo = !self.showInfo;
    },
    vote(option) {
      const self = this;
      const game = self.game;

      const Contract = web3.eth.contract(gameContract.ABI);
      const contract = Contract.at(game.address);

      let fund = prompt(
        `Please enter amount of ETH (minimum ${game.minimumFund / 1e18} ETH)`
      );
      if (fund === null) {
        return;
      } else {
        fund = parseFloat(fund);
      }

      if (isNaN(fund) || fund * 1e18 !== game.minimumFund) {
        return ttr.error("Please enter valid fund");
      }

      self.submitting = true;

      contract.vote.estimateGas(
        option,
        { value: game.minimumFund },
        (err, data) => {
          if (err) {
            self.submitting = false;
            throw err;
          }

          contract.vote.sendTransaction(
            option,
            { value: fund * 1e18, gas: data, gasPrice: 30 * 1e9 },
            (err, data) => {
              if (err) {
                self.submitting = false;
                throw err;
              }

              self.submitting = false;

              const link = `<a class="btn btn-primary" href="${
                web3Helper.viewTxPath
              }/${data}" target="_blank">
        View Transaction on Etherscan</a>`;
              ttr.success(`Transaction Success. ${link}`, null, ttrOption);
            }
          );
        }
      );
    }
  }
};
</script>

