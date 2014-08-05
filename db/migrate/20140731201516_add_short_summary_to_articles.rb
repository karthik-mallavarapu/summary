class AddShortSummaryToArticles < ActiveRecord::Migration
  def change
    add_column :articles, :short_summary, :text
  end
end
