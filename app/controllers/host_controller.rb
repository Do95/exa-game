# The teacher's screen for a live game (projected in class).
class HostController < ApplicationController
  before_action :require_admin
  before_action :load_game, except: %i[new create]

  def new
  end

  def create
    game = Game.build_with_questions(mode: "live", count: params[:count] || 10, kinds: selected_kinds)
    if game.question_ids.empty?
      redirect_to new_host_path, alert: "There are no active questions. Add some in the admin first."
    else
      game.save!
      redirect_to host_path(game)
    end
  end

  def show
    @question = @game.current_question unless @game.status == "lobby"
  end

  def start
    @game.start! if @game.status == "lobby"
    redirect_to host_path(@game)
  end

  def reveal
    @game.reveal!
    redirect_to host_path(@game)
  end

  def next
    @game.next_question! if @game.status == "reveal"
    redirect_to host_path(@game)
  end

  private

  def load_game
    @game = Game.live.find_by!(code: params[:code].to_s.upcase)
  end
end
