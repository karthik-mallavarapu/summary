class AddTimeStampToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :last_updated, :integer, limit: 8
  end
end
