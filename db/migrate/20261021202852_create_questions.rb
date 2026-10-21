class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.string :kind, null: false
      t.string :prompt, null: false
      t.string :hint
      t.json :options
      t.integer :correct_index, null: false, default: 0
      t.text :explanation
      t.integer :time_limit, null: false, default: 20
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :questions, [:kind, :active]
  end
end
