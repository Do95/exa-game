class Game < ApplicationRecord
  MODES = %w[solo live].freeze
  STATUSES = %w[lobby question reveal finished].freeze

  has_many :participants, dependent: :destroy

  validates :mode, inclusion: { in: MODES }
  validates :status, inclusion: { in: STATUSES }
  validates :code, presence: true, uniqueness: true

  before_validation :assign_code, on: :create
  before_validation { self.host_token ||= SecureRandom.hex(16) if live? }

  # Every change in a live game makes the open pages of that game refresh themselves.
  after_update_commit { broadcast_refresh_to self }

  scope :live, -> { where(mode: "live") }

  def self.build_with_questions(mode:, count:, kinds:)
    new(mode: mode, question_ids: pick_question_ids(count, kinds))
  end

  # Spread the questions as evenly as possible across the chosen kinds.
  def self.pick_question_ids(count, kinds)
    kinds = Question::KINDS.keys & Array(kinds)
    kinds = Question::KINDS.keys if kinds.empty?
    count = count.to_i.clamp(3, 40)
    per_kind = kinds.index_with { count / kinds.size }
    kinds.shuffle.first(count % kinds.size).each { |k| per_kind[k] += 1 }
    ids = per_kind.flat_map { |kind, n| Question.active.where(kind: kind).pluck(:id).shuffle.first(n) }
    # If a kind has too few questions, fill the gap with any other active question.
    missing = count - ids.size
    ids += Question.active.where.not(id: ids).pluck(:id).shuffle.first(missing) if missing.positive?
    ids.shuffle
  end

  def solo? = mode == "solo"
  def live? = mode == "live"
  def to_param = code

  def total = question_ids.size
  def question_at(index) = (id = question_ids[index]) && Question.find_by(id: id)
  def current_question = question_at(current_index)
  def last_question? = current_index >= total - 1

  def deadline = question_started_at && current_question && question_started_at + current_question.time_limit.seconds
  def seconds_left = deadline ? [(deadline - Time.current), 0].max : 0

  def ranking = participants.order(score: :desc, correct_count: :desc, created_at: :asc)

  # ---------- Live game flow (driven by the teacher's screen) ----------
  def start!
    update!(status: "question", current_index: 0, question_started_at: Time.current)
  end

  def reveal!
    with_lock { update!(status: "reveal") if status == "question" }
  end

  def next_question!
    if last_question?
      update!(status: "finished")
    else
      update!(status: "question", current_index: current_index + 1, question_started_at: Time.current)
    end
  end

  def answers_for_current = Answer.joins(:participant).where(participants: { game_id: id }, position: current_index)

  def everyone_answered?
    participants.any? && answers_for_current.count >= participants.count
  end

  private

  def assign_code
    self.code ||= loop do
      candidate = rand(100_000..999_999).to_s
      break candidate unless Game.exists?(code: candidate)
    end
  end
end
