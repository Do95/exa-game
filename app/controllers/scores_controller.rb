class ScoresController < ApplicationController
  RANGES = { "today" => "Today", "week" => "This week", "all" => "All time" }.freeze

  def index
    @range = RANGES.key?(params[:range]) ? params[:range] : "today"
    scope = Participant.includes(:game).where("answered_count > 0")
    scope = case @range
            when "today" then scope.where(created_at: Time.current.all_day)
            when "week"  then scope.where(created_at: 1.week.ago..)
            else scope
            end
    @participants = scope.order(score: :desc, created_at: :asc).limit(100)
  end
end
