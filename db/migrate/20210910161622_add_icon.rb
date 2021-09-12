class AddIcon < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :icon, :text, default: false
  end
end
