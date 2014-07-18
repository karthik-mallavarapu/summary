module StopWords
  extend self

  def list
    stop_words = []
    f = File.open("#{Rails.root}/config/stopwords.txt", 'r')
    f.each_line do |line|
      stop_words << line.rstrip
    end
    f.close
    return stop_words
  end

end