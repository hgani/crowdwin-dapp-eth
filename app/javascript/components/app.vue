<template lang='pug'>
  div
    vue-progress-bar

    top-menu(:node='node')

    .container.my-3
      .row
        .col-md-3
          side-menu
        .col-md-9
          router-view
</template>

<script>
export default {
  data() {
    return {
      node: {
        network: null
      }
    };
  },
  created: function() {
    const self = this;

    web3Helper.onCheckInstall(() => {
      if (!web3Helper.metamaskInstalled()) {
        alert("Please install MetaMask");
      }
    });

    web3Helper.onCheckLogin(() => {
      if (!web3Helper.metamaskLogin()) {
        alert("Please login to MetaMask");
      }
    });

    setInterval(
      () =>
        web3Helper.getNetwork((err, net) => {
          self.node.network = net;
        }),
      1000
    );

    $(document).ajaxStart(() => self.$Progress.start());
    $(document).ajaxStop(() => self.$Progress.finish());
  }
};
</script>

