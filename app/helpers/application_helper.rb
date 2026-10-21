module ApplicationHelper
  SHAPES = %w[triangle diamond circle square].freeze

  # The question text, with the gap drawn as a line for "Fill the gap".
  def question_prompt(question, size: :big)
    css = ["prompt", ("prompt-mid" if question.kind.in?(%w[fill swipe fix]) || size == :small)].compact.join(" ")
    text = if question.kind == "fill"
             parts = question.prompt.split("____", 2)
             safe_join([parts[0], tag.span("", class: "blank"), parts[1].to_s, (tag.span("(#{question.hint})", class: "hint") if question.hint.present?)], " ")
           else
             question.prompt
           end
    tag.h2(text, class: css)
  end

  def option_tag_contents(text, index)
    safe_join([tag.span("", class: "shape shape-#{SHAPES[index]}"), tag.span(text, class: "txt")])
  end

  # Countdown ring. With a form id, that form is submitted when the time runs out.
  def countdown(seconds:, total:, submit: nil)
    tag.div(class: "timer", data: { controller: "countdown", countdown_seconds_value: seconds.to_f.round(2),
                                    countdown_total_value: total, countdown_submit_value: submit }) do
      safe_join([
        tag.svg(viewBox: "0 0 92 92", width: "100%", height: "100%") do
          safe_join([tag.circle(class: "track", cx: 46, cy: 46, r: 40),
                     tag.circle(class: "arc", cx: 46, cy: 46, r: 40, data: { countdown_target: "arc" })])
        end,
        tag.b(seconds.ceil, data: { countdown_target: "label" })
      ])
    end
  end

  def mode_badge(game)
    tag.span(game.live? ? "Live" : "Solo", class: "badge badge-#{game.mode}")
  end

  def percent(part, total) = total.to_i.positive? ? (100.0 * part / total).round : 0
end
