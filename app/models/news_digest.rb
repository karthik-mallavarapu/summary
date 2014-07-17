class NewsDigest < ActiveRecord::Base
  
  has_many :articles

  include News

  def generate_digest(date='today')
    self.edition = Chronic.parse(date).strftime('%B %d')
    news_digest = get_latest_digest(date)
    news_digest.each do |topic, arts|
      arts.each do |art|
        self.articles << art
      end
    end
  end
end
