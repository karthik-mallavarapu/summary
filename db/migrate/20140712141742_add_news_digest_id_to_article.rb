class AddNewsDigestIdToArticle < ActiveRecord::Migration
  def change
    add_column :articles, :news_digest_id, :integer
  end
end
