class AddTopicToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :topic, :string
  end
end
