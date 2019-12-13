class HitProductsController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def index
    @data = HitProduct.order("date DESC")
    
    @startNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      currentData.isDeleted = currentData.dead_check
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :dead_check]
  end
  
  def search
    @word = params[:word]
    
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      @data = HitProduct.order("date DESC").where("replace(title, ' ', '') like replace(?, ' ', '')", "%#{@word}%")
    elsif ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      @data = HitProduct.order("date DESC").where("replace(title, ' ', '') ilike replace(?, ' ', '')", "%#{@word}%")
    end
    
    @startNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url]
  end
  
  def condition
    @pageNumber = params[:page].to_i
    
    if @pageNumber == 1
      @startNumber = 0
      @data = HitProduct.order("date DESC").uniq.first(20)
    else
      @startNumber = @pageNumber*10 + @pageNumber*10-20
      @data = HitProduct.order("date DESC").uniq.drop(@startNumber).first(20)
    end
    
    @stackNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      @stackNumber += 1
    end
    
    @tree = { :pageNumber => @pageNumber, :data => @data }
    @dataResult = @tree
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut], :except => [:id, :created_at, :updated_at, :website, :page, :is_sold_out, :image_url]
  end
  
  def web_products_list
    @params = params[:web]
    @data = HitProduct.order("date DESC").where(website: @params)
    
    @stackNumber = 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url]
  end
  
  def rank
    @data = HitProduct.order("score DESC").limit(200)
    
    @startNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    # render :layout => false
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url]
  end
end
