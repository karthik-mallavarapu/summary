class Article < ActiveRecord::Base
  extend FriendlyId

  friendly_id :title, use: :slugged

  belongs_to :category
  validates :title, presence: true
  validates :content, presence: true
  validates :url, presence: true, uniqueness: true
  
  attr_accessor :stem_words

  include Summarizer

  def add_summary
    summary = summarize(self.title, self.content)  
    self.summary = summary
    self.short_summary = summary.split("\n\n")[0]
  end
  
end
