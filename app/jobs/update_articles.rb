class UpdateArticles

  @queue = "update_articles_queue"

  def self.perform
    article_urls = NewsCrawler.get_article_urls
    article_urls.each do |topic, urls|
      c = Category.find_by_name(topic)
      c.update_articles(urls)
    end
  end

end