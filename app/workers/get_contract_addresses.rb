class GetContractAddresses
  include Sidekiq::Worker
  include EthHelper

  def perform
    games = GameContract.where(address: nil)
    games.each do |game|
      receipt = Eth::client.eth_get_transaction_receipt(game.tx_hash)['result']
      game.address = receipt['contractAddress']
      game.save
    end
  end
end
