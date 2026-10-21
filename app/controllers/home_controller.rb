class HomeController < ApplicationController
  def index
    @top = Participant.where(created_at: Time.current.all_day).where("answered_count > 0")
                      .order(score: :desc, created_at: :asc).limit(5)
    @question_count = Question.active.count
  end
end
