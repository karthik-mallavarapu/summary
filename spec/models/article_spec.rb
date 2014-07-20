require 'rails_helper'
require 'spec_helper'

FIXTURES = "#{Rails.root}/spec/fixtures"

describe Article do 

  ['title', 'content', 'url', 'topic'].each do |param|
    it "should have a #{param}"  do
      expect(FactoryGirl.build(:article, param.to_sym => nil)).not_to be_valid
    end
  end

  it "validates uniqueness of url" do 
    article1 = FactoryGirl.create(:article)
    article2 = FactoryGirl.build(:article)
    expect(article2).not_to be_valid
  end

  context "summary" do

    let(:article) {Article.new(YAML.load_file("#{FIXTURES}/articles.yml")['article1'])}

    before {article.add_summary}

    it "generates a summary of article" do
      expect(article.summary).to eq 'The rupee weakened by 27 paise to trade at six-week low of 60.45 against the US dollar in early trade on Friday at the Interbank Foreign Exchange market on high demand for the American currency from importers.'
    end

    it "generates a summary < 100 words" do
      expect(article.summary.length).to be <= 100
    end

  end

end