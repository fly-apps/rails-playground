class CreateSandwiches < ActiveRecord::Migration[7.0]
  def change
    create_table :sandwiches do |t|
      t.string :name
      t.string :category

      t.timestamps
    end
  end
end
