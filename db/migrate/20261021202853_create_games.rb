class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.string :code
      t.string :mode, null: false, default: "solo"
      t.string :status, null: false, default: "lobby"
      t.json :question_ids
      t.integer :current_index, null: false, default: 0
      t.datetime :question_started_at
      t.string :host_token

      t.timestamps
    end
    add_index :games, :code, unique: true
  end
end
