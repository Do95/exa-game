class SoloController < ApplicationController
  before_action :load_game, only: %i[show answer next]

  def new
  end

  def create
    name = params[:name].to_s.squish.presence || "Player"
    game = Game.build_with_questions(mode: "solo", count: params[:count] || 10, kinds: selected_kinds)
    if game.question_ids.empty?
      redirect_to root_path, alert: "There are no active questions yet. Ask your teacher to add some."
      return
    end
    game.save!
    participant = game.participants.create!(name: name.first(22), question_started_at: Time.current)
    remember_player(participant)
    redirect_to solo_path(game)
  end

  def show
    @question = @participant.current_question
    @answer = @participant.answer_at(@participant.current_index) unless @participant.solo_finished?
  end

  def answer
    if params[:position].to_i == @participant.current_index && !@participant.solo_finished?
      @participant.record_answer!(position: @participant.current_index, choice: params[:choice], response: params[:response])
    end
    redirect_to solo_path(@game)
  end

  def next
    @participant.advance! if @participant.answer_at(@participant.current_index)
    redirect_to solo_path(@game)
  end

  private

  def load_game
    @game = Game.find_by!(code: params[:code].to_s.upcase, mode: "solo")
    @participant = current_participant_for(@game)
    redirect_to root_path, alert: "That game belongs to another device. Start a new one!" unless @participant
  end
end
