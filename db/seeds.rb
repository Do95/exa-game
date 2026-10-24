# Loads the Simple Past question bank. Safe to run more than once:
# it only adds questions that are not there yet.
path = Rails.root.join("db/seeds/questions.json")
added = 0
JSON.parse(File.read(path)).each do |q|
  build = q["kind"] == "build"
  correct = build ? q["prompt"] : q["options"][q["correct_index"]]
  already = Question.where(kind: q["kind"], prompt: q["prompt"], hint: q["hint"].presence).any? { |e| e.correct_option == correct }
  next if already

  # Mix the answers so the right one isn't always first (two-choice kinds keep their order).
  options = %w[sort swipe].include?(q["kind"]) ? q["options"] : q["options"].shuffle
  Question.create!(
    kind: q["kind"], prompt: q["prompt"], hint: q["hint"].presence,
    options: options, correct_index: build ? 0 : options.index(correct), explanation: q["explanation"],
    time_limit: Question::KINDS.dig(q["kind"], :time)
  )
  added += 1
end
puts "Questions added: #{added}. Total: #{Question.count}."
