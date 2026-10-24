# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_21_202855) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.integer "participant_id", null: false
    t.integer "question_id", null: false
    t.integer "position"
    t.integer "choice"
    t.boolean "correct", default: false, null: false
    t.integer "points", default: 0, null: false
    t.integer "ms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["participant_id", "position"], name: "index_answers_on_participant_id_and_position", unique: true
    t.index ["participant_id"], name: "index_answers_on_participant_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "code"
    t.string "mode", default: "solo", null: false
    t.string "status", default: "lobby", null: false
    t.json "question_ids"
    t.integer "current_index", default: 0, null: false
    t.datetime "question_started_at"
    t.string "host_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_games_on_code", unique: true
  end

  create_table "participants", force: :cascade do |t|
    t.integer "game_id", null: false
    t.string "name", null: false
    t.string "token"
    t.integer "score", default: 0, null: false
    t.integer "correct_count", default: 0, null: false
    t.integer "answered_count", default: 0, null: false
    t.integer "current_index", default: 0, null: false
    t.datetime "question_started_at"
    t.datetime "finished_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_participants_on_game_id"
    t.index ["token"], name: "index_participants_on_token", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.string "kind", null: false
    t.string "prompt", null: false
    t.string "hint"
    t.json "options"
    t.integer "correct_index", default: 0, null: false
    t.text "explanation"
    t.integer "time_limit", default: 20, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "active"], name: "index_questions_on_kind_and_active"
  end

  add_foreign_key "answers", "participants"
  add_foreign_key "answers", "questions"
  add_foreign_key "participants", "games"
end
