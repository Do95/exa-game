module Admin
  class ScoresController < BaseController
    # Clears every score and game (questions stay).
    def destroy
      Answer.delete_all
      Participant.delete_all
      Game.delete_all
      Turbo::StreamsChannel.broadcast_refresh_to("leaderboard")
      redirect_to scores_path, notice: "All scores were cleared.", status: :see_other
    end
  end
end
