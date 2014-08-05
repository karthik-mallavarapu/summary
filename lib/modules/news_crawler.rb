require 'open-uri'
require 'matrix'

module NewsCrawler
  extend self

  DOUBLE_QUOTES = /[\”\“]/
  SINGLE_QUOTES = /[\’\‘]/

  BASE_URL = 'http://www.thehindu.com/template/1-0-1/widget/archive/archiveWebDayRest.jsp?'

  def get_article_urls(date='today')
    # News categories..pre-defined in topics.yml file..
    news_topics = Konstants.topic_list
    article_urls = Hash.new

    # HTTP request to get a list of all the articles for the given date.
    date = Chronic.parse(date).strftime('%Y-%m-%d')
    timestamp = Time.now.getutc.to_i
    page = get_page("#{BASE_URL}d=#{date}&_=#{timestamp}")
    # Collect article urls for topics in topics.yml
    begin
      news_topics.each do |main_topic, subtopics|
        article_urls[main_topic] = []
        subtopics.each do |topic|
          if page.css("li[data-section='#{topic}']").size > 0            
            links = page.css("li[data-section='#{topic}'] a").map {|li| li['href']}
            article_urls[main_topic] += links
          end
        end
      end
    rescue Exception => e
      puts e.to_s
      print e.backtrace.join("\n")
    end
    return article_urls
  end

  # Fetch title, text and image for an article
  def get_article_content(url)
    article = Hash.new
    page = get_page(url)
    article['title'] = get_title(page)
    article['content'] = get_text(page)
    article['img'] = get_img(page)
    article['last_updated'] = get_last_updated(page)
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
    title = page.css('h1.detail-title').text
    title.gsub!(DOUBLE_QUOTES, "\"")
    title.gsub!(SINGLE_QUOTES, "'")
    return title
  end

  def get_text(page)
    text = []
    page.css('div.article-text p.body').each do |p|
      text << p.text
    end
    text = text.join(' ')
    text.gsub!(DOUBLE_QUOTES, "\"")
    text.gsub!(SINGLE_QUOTES, "'")
    return text
  end

  def get_img(page)
    if img = page.at_css('img.main-image')
      return img['src']
    elsif img = page.at_css('div#pic img')
      return img['src']
    end
  end

  def get_last_updated(page)
    begin
      updated = page.css('div.artPubUpdate').text.strip
      time = Chronic.parse(updated.split('Updated: ')[1])
      return time.getutc.to_i
    rescue Exception => e
      puts "Last updated not found"
    end
  end

end