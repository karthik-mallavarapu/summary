class CreateNewsDigests < ActiveRecord::Migration
  def change
    create_table :news_digests do |t|

      t.timestamps
    end
  end
end
