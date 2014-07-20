class NewsDigest < ActiveRecord::Base
  
  has_many :articles

  include Treat::Core::DSL

  WORD_SANITIZE = /\A[-,:;*^()\/&%{}$!@#=\"'?\”\“]+|[-,:;*^()\/&%{}$!@#=\"'?\”\“]+\z/

  def generate_digest(date='today')
    @date = date
    @stop_words = Konstants.stop_words
    @news_articles = Hash.new
    self.edition = Chronic.parse(@date).strftime('%B %d')
    get_articles
    rank_articles
    self.articles = assort_digest
    self.save
  end

  private

  def assort_digest
    digest = Hash.new
    limits = Konstants.topic_limits
    Konstants.topic_list.each do |main, subtopics|
      main_limit = limits[main]
      subtopics.each do |topic, count|
        if main_limit <= 0
          break
        end
        sorted_articles = @news_articles[main][topic].sort_by {|article| article.score}.reverse
        limit = [count, sorted_articles.size, main_limit].min
        digest[topic] = sorted_articles[0..limit-1]
        main_limit -= limit
      end
    end
    digest_articles = []
    digest.map {|topic, articles| digest_articles += articles}
    return digest_articles
  end

  def rank_articles
    date = Chronic.parse(@date).strftime('%Y-%m-%d').to_date
    Konstants.topic_list.each do |main, subtopics|
      articles = Hash.new
      subtopics.each do |topic, count|
        articles[topic] = Article.where(["created_at > ?", 24.hours.ago]).where(topic: topic)
      end
      @news_articles[main] = articles
    end
    @news_articles.each do |main, subtopics|
      subtopics.each do |topic, articles|
        score_articles(articles)
      end      
    end
  end

  def get_articles
    article_topic_urls = NewsCrawler.get_article_urls(@date)
    article_topic_urls.each do |topic, urls|
      urls.each do |url|
        begin
          if Article.find_by_url(url).nil?
            article = Article.new(NewsCrawler.get_article_content(url))            
            article.topic = topic
            article.url = url
            article.add_summary
            article.save
          end
        rescue Exception => e
          puts e.to_s
          print e.backtrace.join("\n")
        end
      end
    end
  end

  def score_articles(articles)
    article_stems = []
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
      articles[i].save
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

end
