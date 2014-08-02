
module Konstants
  extend self

  def stop_words
    stop_words = []
    f = File.open("#{Rails.root}/config/stopwords.txt", 'r')
    f.each_line do |line|
      stop_words << line.rstrip
    end
    f.close
    return stop_words
  end

  def topic_list
    news_topics = YAML.load_file("#{Rails.root}/config/topics.yml")['Topics']
    return news_topics
  end

end