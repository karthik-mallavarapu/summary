class Article < ActiveRecord::Base

  belongs_to :news_digest
  
  attr_accessor :stem_words

  include Summarizer

  def add_summary
    self.summary = summarize(self.title, self.content)  
  end
  
end
