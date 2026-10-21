module Admin
  class GamesController < BaseController
    def destroy
      game = Game.find_by!(code: params[:code].to_s.upcase)
      game.participants.each { |p| p.answers.delete_all }
      game.destroy
      Turbo::StreamsChannel.broadcast_refresh_to("leaderboard")
      redirect_to admin_questions_path, notice: "Game #{game.code} deleted.", status: :see_other
    end
  end
end
