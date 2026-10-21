class ApplicationController < ActionController::Base
  # Students use all kinds of phones, so no browser-version check here.

  helper_method :admin?

  private

  # Teacher areas (admin, hosting a live game) use one shared password.
  # Change it with the ADMIN_PASSWORD environment variable.
  def require_admin
    authenticate_or_request_with_http_basic("Flashback teacher area") do |user, password|
      ok = ActiveSupport::SecurityUtils.secure_compare(user, ENV.fetch("ADMIN_USER", "admin")) &
           ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch("ADMIN_PASSWORD", "flashback"))
      session[:admin] = true if ok
      ok
    end
  end

  def admin? = session[:admin] == true

  # Each device remembers which player it is in each game.
  def player_cookie(game) = "player_#{game.code}"

  def remember_player(participant)
    cookies.signed[player_cookie(participant.game)] = { value: participant.token, expires: 1.day, httponly: true }
  end

  def current_participant_for(game)
    token = cookies.signed[player_cookie(game)]
    token && game.participants.find_by(token: token)
  end

  def selected_kinds = Array(params[:kinds]).select { |k| Question::KINDS.key?(k) }
end
