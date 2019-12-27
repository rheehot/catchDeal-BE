class HitProductsController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper

  def index
    @currentTime = params[:time]
    
    if @currentTime.nil?
      @currentTime = Time.zone.now
    else
      @currentTime = @currentTime.to_time - 9.hours
    end
    
    @data = HitProduct.where('created_at <= :currnet_time', :currnet_time => @currentTime ).order("date DESC")
    
    @startNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      currentData.isDeleted = currentData.dead_check
      currentData.shortUrl = currentData.redirect_url
      currentData.isTitleChanged = currentData.is_title_changed
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    # render :json => { :latestedData => @dataResult.first.product_id, :data => @dataResult }, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :redirectUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :dead_check, :redirect_url]
    render :json => { :data => @dataResult }, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :dead_check, :redirect_url]
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
      currentData.isDeleted = currentData.dead_check
      currentData.shortUrl = currentData.redirect_url
      currentData.isTitleChanged = currentData.is_title_changed
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :redirect_url]
  end
  
  def condition
    @pageNumber = params[:page].to_i
    @size = params[:size].to_i
    @currentTime = params[:time]
    
    if @size == 0
      @size = 20
    end
    
    if @currentTime.nil?
      @currentTime = Time.zone.now.strftime('%Y-%m-%d %H:%M:%S')
    else
      @currentTime = @currentTime.to_time
    end
    
    if @pageNumber == 1
      @startNumber = 0
      # @data = HitProduct.order("date DESC").uniq.first(@size)
      @data = HitProduct.where('created_at <= :currnet_time', :currnet_time => @currentTime ).order("date DESC").uniq.first(@size)
    else
      @startNumber = @pageNumber * 10 + @pageNumber * (@size-10) - @size
      # @data = HitProduct.order("date DESC").uniq.drop(@startNumber).first(@size)
      @data = HitProduct.where('created_at <= :currnet_time', :currnet_time => @currentTime ).order("date DESC").uniq.drop(@startNumber).first(@size)
    end
    
    @stackNumber = 0
    @stackNumber = @startNumber + 1
    @data.each do |currentData|
      currentData.uid = @stackNumber
      currentData.dateAgo = "#{time_ago_in_words(currentData.date)} 전"
      currentData.shortDate = currentData.date.strftime('%Y-%m-%d %H:%M:%S')
      currentData.imageUrl = currentData.image_url
      currentData.isSoldOut = currentData.is_sold_out
      currentData.isDeleted = currentData.dead_check
      currentData.shortUrl = currentData.redirect_url
      currentData.isTitleChanged = currentData.is_title_changed
      @stackNumber += 1
    end
    
    @tree = { :pageNumber => @pageNumber, :sizeOfPage => @size, :data => @data }
    @dataResult = @tree
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :page, :is_sold_out, :image_url, :redirect_url]
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
      currentData.isDeleted = currentData.dead_check
      currentData.shortUrl = currentData.redirect_url
      currentData.isTitleChanged = currentData.is_title_changed
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :redirect_url]
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
      currentData.isDeleted = currentData.dead_check
      currentData.shortUrl = currentData.redirect_url
      currentData.isTitleChanged = currentData.is_title_changed
      @stackNumber += 1
    end
    
    @dataResult = @data
    
    # render :layout => false
    render :json => @dataResult, :methods => [:dateAgo, :shortDate, :uid, :imageUrl, :isSoldOut, :isDeleted, :isTitleChanged, :shortUrl], :except => [:id, :created_at, :updated_at, :website, :is_sold_out, :image_url, :redirect_url]
  end
end
