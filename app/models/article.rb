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
  
  def related_articles
    category = Category.find(self.category_id)
    related_articles = category.articles.where(["created_at > ?", 24.hours.ago]).where(["id != ?", self.id]).order('score DESC').limit(5).order('created_at DESC')
    related_articles
  end

  def last_updated_time
    ChronicDuration.output(Time.now - self.created_at, units: 1, format: :long)
  end

end
