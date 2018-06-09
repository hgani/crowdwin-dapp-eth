export default {
  validateGameForm(game, cb) {
    if (!web3Helper.metamaskLogin()) {
      return alert("Please login to MetaMask");
    }

    const closingTime = new Date(game.closingTime);

    if (!game.closingTime || closingTime < game.minimumTime) {
      return ttr.error("Please enter valid closing time. Closing time must be greater than now");
    }
    if (!game.label) {
      return ttr.error("Please enter valid label");
    }
    for (const item of game.options) {
      if (!item) return ttr.error("Please enter valid option");
    }

    return cb && cb();
  }
}