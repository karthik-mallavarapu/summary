class CategoriesController < ApplicationController

  def index
    @edition = Chronic.parse('today').strftime('%B %d')
    @latest_articles = Hash.new
    Category.all.each do |c|
      @latest_articles[c.name] = c.articles.where(["created_at > ?", 24.hours.ago]).order('score DESC').where(["img != ?", 'nil']).limit(3)
    end
    @digest = []
    @latest_articles.each do |topic, articles|
      @digest += articles[0..1]
    end
  end

  def show
    category = Category.friendly.find(params[:id])
    @articles = category.articles.where(["created_at > ?", 24.hours.ago]).order('score DESC').limit(10).order('created_at DESC')
    @title = category.name
  end

end
