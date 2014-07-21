class NewsDigestController < ApplicationController


  def index
    @digest = NewsDigest.order(:created_at).last
    @edition = @digest.edition
    @articles = @digest.articles
  end

  def latest_digest
    @digest = NewsDigest.order(:created_at).last
    articles = []
    @digest.articles.each do |article|
      articles << {'title' => article.title, 'img' => article.img, 'url' => article.url, 'summary' => article.summary.split("\n\n")[0]}
    end
    render json: {articles: articles, updated_at: @digest.created_at.to_s}
  end

end
