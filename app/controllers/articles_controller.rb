class ArticlesController < ApplicationController
  
  def show
    category = Category.friendly.find(params[:category_id])
    @article = category.articles.friendly.find(params[:id])
    @other_articles = @article.related_articles
    @category_name = category.name
  end

  private

end
