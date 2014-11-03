
module Summarizer
  extend ActiveSupport::Concern
  include Treat::Core::DSL

  WORD_SANITIZE = /\A[-,:;*^()\/&%{}$!@#=\’?\”\“]+|[-,:;*^()\/&%{}$!@#=\’?\”\“]+\z/

  def summarize(title, content)
    if word_count(content) < 100
      return content
    end
    @sentence_stems = []
    @sentence_similarity_scores = []
    temp = Tempfile.new("article")
    temp << content
    temp.close
    @text = document(temp.path)
    @text.apply(:chunk, :segment, :tokenize)
    @stop_words = Konstants.stop_words
    @title_stem = title_stem(title)
    sentence_stems
    sentence_similarity
    generate_summary
  end

  def sentence_similarity
    @sentence_stems.each_index do |i|
      scores = []
      @sentence_stems.each_index do |j|
        score = calculate_score(@sentence_stems[i], @sentence_stems[j])
        scores << score
      end
      @sentence_similarity_scores << scores
    end
  end

  def generate_summary
    sorted_sentences = Hash[weights.sort_by {|key, value| value}.reverse]
    summary = []
    sorted_sentences.each do |index, weight|
      sentence = @text.sentences[index].value
      next if (word_count(sentence) < 15 || word_count(sentence) >= 100)
      break if word_count(summary.join(' ') + sentence) >= 100
      # Removing quotation marks until the multi-sentence quotation issue is fixed
      sentence = sentence.split(" ").
      map { |word| word.gsub(/\A([\"]*[\.]*)+|([\"]*[\.]*)\z/, "") }.join(" ")
      # Removes word quotation and periods from the sentence. So adding the period back.
      sentence << "."
      summary << sentence
    end
    summary.join(" \n\n")
  end

  def weights
    weights = {}
    # Damping factor
    d = 0.85
    # Add an initial weight of 1
    @text.sentences.size.times do |i|
      weights[i] = 1.0
    end
    # Iterate 30 times to calculate final weights of sentences
    # Convergence curves indicate that error rate is negligible by the 30th iteration
    30.times do
      @sentence_similarity_scores.each_index do |i|
        scores = @sentence_similarity_scores[i]
        temp = 0.0
        scores.each_index do |j|
          sum_score_j = 0.0
          @sentence_similarity_scores[j].map {|score| sum_score_j += score }
          if sum_score_j != 0.0
            temp += weights[j] * (scores[j] / sum_score_j)
          end
        end
        weights[i] = (1 - d) + d * temp
      end
    end
    weights
  end

=begin
TODO
  def get_quotations(content)
    start_quotes = /\A[\"]/
    end_quotes = /[\"]\z/
    words = content.split(' ')
    search_pattern = start_quotes
    indices = []
    words.each_index do |i|
      if matches?(words[i], search_pattern)
        indices << i
        search_pattern = end_quotes
      end
    end
    return words[indices[0]..indices[1]].join(' ')
  end
=end
  private

  # Iterate through all the sentences to remove stop words and store stems of words.
  def sentence_stems
    @text.sentences.each do |sentence|
      @sentence_stems << sanitize_sentence(sentence)
    end
  end

  def matches?(string, pattern)
    !!(string =~ pattern)
  end

  def title_stem(title)
    title_token = sentence title
    title_token.tokenize unless title_token.has_children?
    return sanitize_sentence(title_token)
  end

  def sanitize_sentence(sentence)
    sentence_stem = Hash.new(0)
    sentence.tokens.each do |w|
      word = w.value.downcase
      word.gsub!(WORD_SANITIZE, '')
      next if word.length == 0
      if !@stop_words.include? word
        if w.class == Treat::Entities::Word
          sentence_stem[word.stem] += 1
        end
      end
    end
    return sentence_stem
  end

  def calculate_score(sentence_stem1, sentence_stem2)
    score = 0.0
    sentence_stem1.each do |stem, freq|
      score += [freq, sentence_stem2[stem]].min
      score += [freq, @title_stem[stem]].min
    end
    normalize = (Math.log(sentence_len(sentence_stem1)) + Math.log(sentence_len(sentence_stem2)))
    if normalize != 0
      score /= normalize
    else
      score = 0.0
    end
    return score
  end

  def word_count(sentence)
    return sentence.split(" ").size
  end

  def sentence_len(sentence_stem)
    total_count = 0
    sentence_stem.map { |stem, count| total_count += count}
    return total_count
  end

end
