# Students in a live game: join with a code, then answer on their phone.
class PlayersController < ApplicationController
  before_action :load_game, only: %i[show answer]

  def new
    @code = params[:code].to_s.upcase
  end

  def create
    @code = params[:code].to_s.upcase.strip
    game = Game.live.find_by(code: @code)
    if game.nil? || game.status == "finished"
      flash.now[:alert] = "We couldn't find a live game with that code."
      render :new, status: :unprocessable_entity
      return
    end
    participant = current_participant_for(game) ||
                  game.participants.create(name: params[:name].to_s.squish.first(22).presence || "Player")
    remember_player(participant)
    redirect_to play_path(game)
  end

  def show
    @question = @game.current_question
    @answer = @participant.answer_at(@game.current_index) if @question
  end

  def answer
    if @game.status == "question" && params[:position].to_i == @game.current_index
      @participant.record_answer!(position: @game.current_index, choice: params[:choice])
      @game.reveal! if @game.everyone_answered?
    end
    redirect_to play_path(@game)
  end

  private

  def load_game
    @game = Game.live.find_by!(code: params[:code].to_s.upcase)
    @participant = current_participant_for(@game)
    redirect_to join_path(code: @game.code) unless @participant
  end
end
