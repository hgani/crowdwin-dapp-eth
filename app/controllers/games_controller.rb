class GamesController < ApplicationController
  def index
    games = GameContract.where.not(address: nil).order(created_at: :desc)
    respond_to do |format|
      format.json do
        render(json: { games: games, pagination: {} })
      end
    end
  end

  def show
    game = GameContract.where('lower(address) = lower(?)', params[:id]).first
    respond_to do |format|
      format.json do
        render(json: { game: game })
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        tx_hash = params[:tx_hash]
        creator = params[:creator]
        label = params[:label]
        description = params[:description]
        options = params[:options]

        game = GameContract.create(
          tx_hash: tx_hash,
          creator: creator,
          label: label,
          description: description,
          options: options
        )
        game.save!
      end
    end
  end

  def update
    game = GameContract.find_by(address: params[:id])

    respond_to do |format|
      format.json do
        game.label = params[:label]
        game.description = params[:description]
        game.options = params[:options]

        game.save!
      end
    end
  end
end
