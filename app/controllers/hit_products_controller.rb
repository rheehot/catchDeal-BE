class HitProductsController < ApplicationController
  require 'action_view'
  require 'action_view/helpers'
  include ActionView::Helpers::DateHelper
  include HitProductsHelper

  def index
    @currentTime = params[:time]
    
    if @currentTime.nil?
      @currentTime = Time.zone.now
    else
      @currentTime = @currentTime.to_time - 9.hours
    end
    
    @data = HitProduct.where('created_at <= :currnet_time', :currnet_time => @currentTime ).order("date DESC")
    
    @user = auth_user_check(request.headers['Authorization'])
    @data = attr_refactory(@data, @user)
    
    if @user == false
      @userTokenBoolean = false
    else
      @userTokenBoolean = true
    end
    
    @dataResult = { :data => @data }
    @dataResult = product_json(@dataResult)
    render :json => @dataResult
  end
  
  def search
    @word = params[:word]
    
    if ActiveRecord::Base.connection.adapter_name == 'SQLite'
      @data = HitProduct.order("date DESC").where("replace(title, ' ', '') like replace(?, ' ', '')", "%#{@word}%")
    elsif ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      @data = HitProduct.order("date DESC").where("replace(title, ' ', '') ilike replace(?, ' ', '')", "%#{@word}%")
    end
    
    @user = auth_user_check(request.headers['Authorization'])
    @data = attr_refactory(@data, @user)
    
    if @user == false
      @userTokenBoolean = false
    else
      @userTokenBoolean = true
    end
    
    @dataResult = { :data => @data }
    @dataResult = product_json(@dataResult)
    render :json => @dataResult
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
      @currentTime = @currentTime.to_time.strftime('%Y-%m-%d %H:%M:%S')
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
    
    @user = auth_user_check(request.headers['Authorization'])
    @data = attr_refactory(@data, @user)
    
    if @user == false
      @userTokenBoolean = false
    else
      @userTokenBoolean = true
    end
    
    @dataResult = { :pageNumber => @pageNumber, :sizeOfPage => @size, :time => @currentTime, :data => @data }
    @dataResult = product_json(@dataResult)
    
    render :json => @dataResult
  end
  
  def web_products_list
    @params = params[:web]
    @data = HitProduct.order("date DESC").where(website: @params)
    
    @user = auth_user_check(request.headers['Authorization'])
    @data = attr_refactory(@data, @user)
    
    if @user == false
      @userTokenBoolean = false
    else
      @userTokenBoolean = true
    end
    
    @dataResult = { :data => @data }
    @dataResult = product_json(@dataResult)
    render :json => @dataResult
  end
  
  def rank
    @data = HitProduct.order("score DESC").limit(100)
    
    @user = auth_user_check(request.headers['Authorization'])
    @data = attr_refactory(@data, @user)
    
    if @user == false
      @userTokenBoolean = false
    else
      @userTokenBoolean = true
    end
    
    @dataResult = { :data => @data }
    @dataResult = product_json(@dataResult)
    render :json => @dataResult
  end
end
