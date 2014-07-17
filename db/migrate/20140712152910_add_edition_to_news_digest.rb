class AddEditionToNewsDigest < ActiveRecord::Migration
  def change
    add_column :news_digests, :edition, :string
  end
end
