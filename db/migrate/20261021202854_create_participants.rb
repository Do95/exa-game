class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants do |t|
      t.references :game, null: false, foreign_key: true
      t.string :name, null: false
      t.string :token
      t.integer :score, null: false, default: 0
      t.integer :correct_count, null: false, default: 0
      t.integer :answered_count, null: false, default: 0
      t.integer :current_index, null: false, default: 0
      t.datetime :question_started_at
      t.datetime :finished_at

      t.timestamps
    end
    add_index :participants, :token, unique: true
  end
end
