class RemoveTopicFromArticles < ActiveRecord::Migration
  def change
    remove_column :articles, :topic, :string
  end
end
