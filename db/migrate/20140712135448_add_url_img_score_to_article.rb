class AddUrlImgScoreToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :url, :string
    add_column :articles, :img, :string
    add_column :articles, :score, :decimal
  end
end
