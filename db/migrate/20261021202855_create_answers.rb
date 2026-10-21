class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers do |t|
      t.references :participant, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.integer :position
      t.integer :choice
      t.boolean :correct, null: false, default: false
      t.integer :points, null: false, default: 0
      t.integer :ms

      t.timestamps
    end
    add_index :answers, [:participant_id, :position], unique: true
  end
end
