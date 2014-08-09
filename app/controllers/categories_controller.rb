class CategoriesController < ApplicationController

  def index
    @latest_articles = Hash.new
    Category.all.each do |c|
      @latest_articles[c.name] = c.articles.where(["created_at > ?", 15.hours.ago]).where(["img != ?", 'nil']).limit(3).sort_by(&:created_at).reverse[0..2]
    end
    @digest = []
    @latest_articles.each do |topic, articles|
      @digest += articles[0..1]
    end
  end

  def show
    category = Category.friendly.find(params[:id])
    @articles = category.articles.where(["created_at > ?", 15.hours.ago]).order('score DESC').limit(10).sort_by(&:created_at).reverse
    @updated_times = []
    @articles.each do |article|
      @updated_times << "#{article.last_updated_time} ago"
    end
    @title = category.name
  end

end
