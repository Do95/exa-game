class Answer < ApplicationRecord
  belongs_to :participant
  belongs_to :question

  # Everything above the 500 points for being right comes from answering fast.
  def speed_bonus = correct ? points - 500 : 0
  def seconds = (ms.to_i / 1000.0).round(1)
end
