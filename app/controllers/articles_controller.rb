class ArticlesController < ApplicationController
  
  def show
    @article = Category.friendly.find(params[:category_id]).articles.friendly.find(params[:id])
  end

  private

end
