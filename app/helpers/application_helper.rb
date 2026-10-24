module ApplicationHelper
  SHAPES = %w[triangle diamond circle square].freeze

  # The question text, with the gap drawn as a line for "Fill the gap".
  # "Build the sentence" shows its mixed-up words instead (the prompt is the answer).
  def question_prompt(question, size: :big)
    return tag.div(safe_join(question.tiles.map { |w| tag.span(w, class: "tile") }), class: "tiles tiles-static") if question.build?

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

  # "Correct! +812 · 500 + 312 for speed (4.1 s)"
  def points_breakdown(answer)
    return unless answer&.correct
    "500 + #{answer.speed_bonus} for speed (#{answer.seconds} s)"
  end

  # Each question and state gets its own screen id. Moving on then replaces the whole screen
  # (fresh animations, timer, buttons, scroll) instead of patching the previous one in place.
  def screen_id(game, *step) = ["screen", game.code, *step].join("-")

  # QR code as inline SVG, so students can scan the board to join.
  def qr_code(url)
    svg = RQRCode::QRCode.new(url).as_svg(module_size: 6, standalone: true, use_path: true, viewbox: true, color: "14315A").sub(/\A<\?xml[^>]*>/, "")
    tag.div(svg.html_safe, class: "qr", role: "img", aria: { label: "QR code to join the game" })
  end

  def mode_badge(game)
    tag.span(game.live? ? "Live" : "Solo", class: "badge badge-#{game.mode}")
  end

  def percent(part, total) = total.to_i.positive? ? (100.0 * part / total).round : 0
end
