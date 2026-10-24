class AddResponseToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_column :answers, :response, :string
  end
end
