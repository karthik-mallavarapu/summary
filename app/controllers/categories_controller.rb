class CategoriesController < ApplicationController

  def index
    @latest_articles = Hash.new
    Category.all.each do |c|
      @latest_articles[c.name] = c.articles.where(["created_at > ?", 15.hours.ago]).where(["img != ?", 'nil']).sort_by(&:created_at).reverse[0..2]
    end
    @digest = []
    @latest_articles.each do |topic, articles|
      @digest += articles[0..1]
    end
  end

  def show
    category = Category.friendly.find(params[:id])
    @articles = category.articles.where(["created_at > ?", 15.hours.ago]).limit(10).sort_by(&:created_at).reverse
    @title = category.name
  end

end
