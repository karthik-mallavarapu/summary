require 'rails_helper'
require 'spec_helper'

FIXTURES = "#{Rails.root}/spec/fixtures"

describe "Summarizer" do

  before do 
    class Dummy 
      include Summarizer 
    end
  end

  context "for very short articles" do

    let(:article) {YAML.load_file("#{FIXTURES}/articles.yml")['article2']}
    let(:dummy) {Dummy.new}

    it "summary is equal to article content when length of article < 100 words" do
      expect(dummy.summarize(article['title'], article['content'])).to eq article['content']
    end

  end

  context "includes important punctuations like quotations" do

    let(:dummy) { Dummy.new}

    it "finds a quotation from text" do 
      str = "\"This is a quotation\" said someone."
      expect(dummy.get_quotations(str)).to eq "\"This is a quotation\""
    end

    it "finds a quotation even with other punctuations" do 
      str = "\"This is a quotation in it's simplest form\" said someone."
      expect(dummy.get_quotations(str)).to eq "\"This is a quotation in it's simplest form\""
    end

  end


end