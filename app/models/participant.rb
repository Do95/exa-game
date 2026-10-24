class Participant < ApplicationRecord
  belongs_to :game
  has_many :answers, dependent: :delete_all

  validates :name, presence: true, length: { maximum: 22 }
  before_validation { self.name = name.to_s.squish }
  before_validation(on: :create) { self.token ||= SecureRandom.hex(16) }

  # Scores show up live on the leaderboard and on the game's screens.
  after_commit :broadcast_changes

  # Points: 500 for a correct answer plus up to 500 for speed. Wrong or late: 0.
  # "Build the sentence" sends the built sentence as `response`; its choice is 0 (right), 1 (wrong) or -1 (no answer).
  def record_answer!(position:, choice:, response: nil)
    question = game.question_at(position) or return nil
    started = game.live? ? game.question_started_at : question_started_at
    limit = question.time_limit.seconds
    ms = started ? ((Time.current - started) * 1000).round : limit.in_milliseconds
    on_time = ms <= limit.in_milliseconds + 1500 # a little grace for slow phones
    if question.build?
      response = nil if choice.to_i.negative?
      correct = on_time && response.present? && question.build_matches?(response)
      choice = response.nil? ? -1 : (correct ? 0 : 1)
    else
      response = nil
      correct = on_time && choice.to_i == question.correct_index
    end
    points = correct ? 500 + (500 * (1 - [ms, limit.in_milliseconds].min.to_f / limit.in_milliseconds)).round : 0

    transaction do
      answer = answers.create!(question: question, position: position, choice: choice.to_i, response: response.to_s.squish.first(250).presence, correct: correct, points: points, ms: ms)
      update!(score: score + points, correct_count: correct_count + (correct ? 1 : 0), answered_count: answered_count + 1)
      answer
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    answers.find_by(position: position)
  end

  def answer_at(position) = answers.find_by(position: position)

  def rank = game.ranking.pluck(:id).index(id).to_i + 1

  # ---------- Solo flow ----------
  def solo_finished? = current_index >= game.total
  def current_question = game.question_at(current_index)
  def seconds_left
    q = current_question
    return 0 unless q && question_started_at
    [(question_started_at + q.time_limit.seconds - Time.current), 0].max
  end

  def advance!
    if current_index + 1 >= game.total
      update!(current_index: game.total, finished_at: Time.current)
    else
      update!(current_index: current_index + 1, question_started_at: Time.current)
    end
  end

  private

  def broadcast_changes
    broadcast_refresh_to game if game.live?
    broadcast_refresh_to "leaderboard"
  end
end
