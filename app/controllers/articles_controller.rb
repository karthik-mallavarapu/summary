class ArticlesController < ApplicationController
  
  def index
    @articles = Article.all
  end

  def new
    @article = Article.new
  end

  def show
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(article_params)
    @article.add_metadata
    if @article.save
      flash[:notice] = "New article has been created"
      redirect_to @article
    else
      flash[:alert] = "Article has not been created"
      render action: "new"
    end
  end

  def summary
    @article = Article.new(article_params)
    summary = @article.get_summary 
    render json: {summary: summary, status: 'ok'}
  end

  private


  def article_params
    params.require(:article).permit(:title, :content)
  end

end
