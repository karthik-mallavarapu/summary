require 'open-uri'
require 'matrix'

module News
  extend ActiveSupport::Concern
  include Treat::Core::DSL

  WORD_SANITIZE = /\A[-,:;*^()\/&%{}$!@#=\"'?\”\“]+|[-,:;*^()\/&%{}$!@#=\"'?\”\“]+\z/

  BASE_URL = 'http://www.thehindu.com/template/1-0-1/widget/archive/archiveWebDayRest.jsp?'


  def get_latest_digest(date)
    @data_sections = Hash.new
    @news_articles = Hash.new
    @topics = Hash.new
    date = Chronic.parse(date).strftime('%Y-%m-%d')
    timestamp = Time.now.getutc.to_i
    page = get_page("#{BASE_URL}d=#{date}&_=#{timestamp}")
    news_links = page.css("li")
    news_links.each do |li|
      if @data_sections[li['data-section']].nil?
        @data_sections[li['data-section']] = []
      end
      @data_sections[li['data-section']] << li.css('a').first['href']
    end
    get_articles
    rank_articles
    extract_digest
  end

  private
  
  def get_articles
    relevant_links = Hash.new
    @topics = YAML.load_file("#{Rails.root}/config/topics.yml")['topics']
    @topics.each do |topic, count|
      relevant_links[topic] = @data_sections[topic]
    end
    Parallel.map(relevant_links, :in_threads => 5) do |key, values|
      begin
        @news_articles[key] = []
        values.each do |link|
          page = get_page(link)
          if page.nil? 
            puts "Problem with this link #{link}"
            next
          end
          article = Article.new(title: get_title(page), content: get_content(page), url: link, 
            last_updated: get_last_updated(page), img: get_img(page), topic: key)
          article.add_summary
          article.img = '/assets/no.png' if article.img.nil?
          if article.content.length != 0
            @news_articles[key] << article
          else
            puts "Problem with this link #{link}"          
          end
        end
      rescue Exception => e
        puts "#{e.to_s}....topic: #{key}"
        print e.backtrace.join("\n")
      end
    end
  end

  def rank_articles
    Parallel.map(@news_articles, :in_threads => 5) do |topic, articles|
      score_articles(articles)
    end
    @filtered_articles = Hash.new
    Parallel.map(@news_articles, :in_threads =>5) do |topic, articles|
      @filtered_articles[topic] = articles
      similar_articles = []
      corpus = []
      articles.each do |article| 
        corpus << TfIdfSimilarity::Document.new(article.content)
      end
      model = TfIdfSimilarity::TfIdfModel.new(corpus)
      similarity_matrix = model.similarity_matrix.to_a
      similarity_matrix.each_index do |i|
        similarity_matrix[i].each_index do |j|
          if i == j
            next
          end
          if similarity_matrix[i][j] > 0.5
            article = (articles[i].last_updated > articles[j].last_updated)? articles[j] : articles[i]
            similar_articles << article
          end
        end
      end
      similar_articles.uniq!
      similar_articles.each do |article|
        @filtered_articles[topic].delete article
      end
      @filtered_articles[topic].sort_by! {|article| article.score}
    end

  end

  def extract_digest
    digest = Hash.new
    @filtered_articles.each do |topic, articles|
      digest[topic] = []
      article_count = [@topics[topic], articles.size].min
      last_index = articles.size - 1
      article_count.times do |i|
        digest[topic] << articles[last_index - i]
      end
    end
    return digest
  end


  def score_articles(articles)
    article_stems = []
    stopwords
    articles.each do |article|
      article.stem_words = article_stem(article)
    end
    articles.each_index do |i|
      score = 0.0
      articles.each_index do |j|
        if i == j
          next
        end
        temp_score = common_stems(articles[i].stem_words, articles[j].stem_words)
        temp_score /= (Math.log(stem_count(articles[i])) + Math.log(stem_count(articles[j])))
        score += temp_score
      end
      articles[i].score = score
    end
  end

  def common_stems(article1, article2)
    common_score = 0
    article1.each do |stem, count|
      common_score += [count, article2[stem]].min
    end
    return common_score
  end

  def stem_count(article)
    total_count = 0
    article.stem_words.map { |stem, count| total_count += count }
    return total_count
  end

  def article_stem(article)
    article_stem = Hash.new(0)
    temp = Tempfile.new("article")
    temp << article.content
    temp.close
    text = document(temp.path)
    text.apply(:chunk, :segment, :tokenize)
    text.tokens.each do |w|
      word = w.value.downcase
      word.gsub!(WORD_SANITIZE, '')
      next if word.length == 0
      if !@stop_words.include? word
        if w.class == Treat::Entities::Word 
          article_stem[word.stem] += 1
        end
      end
    end
    return article_stem
  end

  def stopwords
    @stop_words = []
    f = File.open("config/stopwords.txt", 'r')
    f.each_line do |line|
      @stop_words << line.rstrip
    end
    f.close
  end

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

  def get_content(page)
    content = []
    page.css('div.article-text p.body').each do |p|
      content << p.text
    end
    return content.join(' ')
  end

  def get_img(page)
    if img = page.at_css('img.main-image')
      img['src']
    end
  end

  def get_last_updated(page)
    updated = page.css('div.artPubUpdate').text.strip
    time = Chronic.parse(updated.split('Updated: ')[1])
    return time.getutc.to_i
  end

end