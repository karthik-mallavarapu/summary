class AddEditionToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :edition, :string
  end
end
