class Category < ActiveRecord::Base
  extend FriendlyId

  friendly_id :name
  has_many :articles

  validates :name, presence: true, uniqueness: true

  include Treat::Core::DSL

  WORD_SANITIZE = /\A[-,:;*^()\/&%{}$!@#=\"'?\”\“]+|[-,:;*^()\/&%{}$!@#=\"'?\”\“]+\z/


  def update_articles(urls)
    @stop_words = Konstants.stop_words
    get_latest_articles(urls)
    delete_similar_articles
    score_articles
  end

  private

  def get_latest_articles(urls)
    urls.each do |url|
      begin
        if self.articles.find_by_url(url).nil?
          article = Article.new(NewsCrawler.get_article_content(url))            
          article.url = url
          article.add_summary
          article.edition = Chronic.parse('today').strftime('%B %d')
          article.save
          self.articles << article
        end
      rescue Exception => e
        puts e.to_s
        print e.backtrace.join("\n")
      end
    end
  end

  def delete_similar_articles
    articles = self.articles.where(["created_at > ?", 24.hours.ago])
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
        if similarity_matrix[i][j] > 0.30
          article = (articles[i].last_updated > articles[j].last_updated)? articles[j] : articles[i]
          article.delete
        end
      end
    end
  end

  def score_articles
    articles = self.articles.where(["created_at > ?", 24.hours.ago])
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