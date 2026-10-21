module Admin
  class QuestionsController < BaseController
    before_action :set_question, only: %i[edit update destroy toggle]

    def index
      @kind = Question::KINDS.key?(params[:kind]) ? params[:kind] : nil
      @q = params[:q].to_s.strip
      scope = Question.order(:kind, :prompt)
      scope = scope.where(kind: @kind) if @kind
      if @q.present?
        like = "%#{Question.sanitize_sql_like(@q.downcase)}%"
        scope = scope.where("LOWER(prompt) LIKE :q OR LOWER(CAST(options AS TEXT)) LIKE :q OR LOWER(COALESCE(hint, '')) LIKE :q", q: like)
      end
      @questions = scope
      @counts = Question.group(:kind).count
      @active_counts = Question.active.group(:kind).count
      @games = Game.live.order(created_at: :desc).limit(5)
    end

    def new
      @question = Question.new(kind: params[:kind].presence_in(Question::KINDS.keys) || "irregular", options: [])
      @question.time_limit = Question::KINDS.dig(@question.kind, :time)
    end

    def create
      @question = Question.new(question_params)
      if @question.save
        redirect_to admin_questions_path(kind: @question.kind), notice: "Question added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @question.update(question_params)
        redirect_to admin_questions_path(kind: @question.kind), notice: "Question saved."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @question.destroy
      redirect_to admin_questions_path(kind: @question.kind), notice: "Question deleted.", status: :see_other
    end

    def toggle
      @question.update!(active: !@question.active)
      redirect_back fallback_location: admin_questions_path, status: :see_other
    end

    private

    def set_question = @question = Question.find(params[:id])

    def question_params
      params.require(:question).permit(:kind, :prompt, :hint, :options_text, :correct_number, :explanation, :time_limit, :active)
    end
  end
end
