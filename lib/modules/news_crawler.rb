require 'open-uri'
require 'matrix'

module NewsCrawler
  extend self

  BASE_URL = 'http://www.thehindu.com/template/1-0-1/widget/archive/archiveWebDayRest.jsp?'

  include Treat::Core::DSL

  def get_article_urls(date='today')
    # News categories..pre-defined in topics.yml file..
    news_topics = YAML.load_file("#{Rails.root}/config/topics.yml")['Topics']
    article_urls = Hash.new

    # HTTP request to get a list of all the articles for the given date.
    date = Chronic.parse(date).strftime('%Y-%m-%d')
    timestamp = Time.now.getutc.to_i
    page = get_page("#{BASE_URL}d=#{date}&_=#{timestamp}")
    # Collect article urls for topics in topics.yml
    news_topics.each do |topic, count|
      if page.css("li[data-section=#{topic}]").size > 0
        topic_links = page.css("li[data-section=#{topic} a]").map {|li| li['href']}
        article_urls[topic] = topic_links
      end
    end
  end

  # Fetch title, text and image for an article
  def get_article_content(url)
    article = Hash.new
    page = get_page(url)
    article['title'] = get_title(page)
    article['text'] = get_text(page)
    article['img'] = get_img(page)
    return article
  end

  private 

  def get_page(url)
    tries ||= 3
    begin
      page = Nokogiri::HTML(open(url, read_timeout: 15))
      return page
    rescue
      retry unless (tries -= 1).zero?
    end
  end

  def get_title(page)
    page.css('h1.detail-title').text
  end

  def get_text(page)
    text = []
    page.css('div.article-text p.body').each do |p|
      text << p.text
    end
    return text.join(' ')
  end

  def get_img(page)
    if img = page.at_css('img.main-image')
      return img['src']
    end
    return '/assets/no.png'
  end

end