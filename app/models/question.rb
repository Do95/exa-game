class Question < ApplicationRecord
  # Each kind of challenge, with the instruction students see and its default time.
  KINDS = {
    "irregular" => { label: "Irregular sprint",      instruction: "What is the past form?",           time: 15 },
    "sort"      => { label: "Regular or irregular?", instruction: "Is this verb regular or irregular?", time: 12 },
    "swipe"     => { label: "Simple Past or not?",   instruction: "Is this sentence in Simple Past?",  time: 12 },
    "fill"      => { label: "Fill the gap",          instruction: "Choose the correct form.",         time: 18 },
    "fix"       => { label: "Fix the mistake",       instruction: "Only one sentence is correct.",    time: 25 }
  }.freeze

  has_many :answers, dependent: :delete_all

  validates :kind, inclusion: { in: KINDS.keys }
  validates :prompt, presence: true, length: { maximum: 200 }
  validates :time_limit, numericality: { only_integer: true, in: 5..90 }
  validate :options_are_valid

  scope :active, -> { where(active: true) }

  before_validation :clean_options
  before_validation { self.time_limit ||= KINDS.dig(kind, :time) || 20 }

  def kind_label = KINDS.dig(kind, :label) || kind.to_s.humanize
  def instruction = KINDS.dig(kind, :instruction).to_s
  def correct_option = options[correct_index]

  # The admin form edits options as one per line and the correct answer as a number from 1.
  def options_text = Array(options).join("\n")
  def options_text=(text)
    self.options = text.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end

  def correct_number = correct_index.to_i + 1
  def correct_number=(n)
    self.correct_index = n.to_i - 1
  end

  private

  def clean_options
    self.options = Array(options).map { |o| o.to_s.strip }.reject(&:blank?)
  end

  def options_are_valid
    if options.size < 2 || options.size > 4
      errors.add(:options, "must have between 2 and 4 answers (one per line)")
    elsif correct_index.negative? || correct_index >= options.size
      errors.add(:correct_number, "must be between 1 and #{options.size}")
    end
  end
end
