class Article < ActiveRecord::Base

  belongs_to :news_digest
  validates :title, presence: true
  validates :content, presence: true
  validates :topic, presence: true
  validates :url, presence: true, uniqueness: true
  
  attr_accessor :stem_words

  include Summarizer

  def add_summary
    self.summary = summarize(self.title, self.content)  
  end
  
end
