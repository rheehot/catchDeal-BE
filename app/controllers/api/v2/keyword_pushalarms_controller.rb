class Api::V2::KeywordPushalarmsController < ApplicationController
    require 'action_view'
    require 'action_view/helpers'
    include ActionView::Helpers::DateHelper
    include HitProductsHelper
    before_action :jwt_authenticate_request!
    
    def send_pushalarm
  	    json_params = JSON.parse(request.body.read)
  	
      	if ENV["PUSHALARM_PASSWORD"] == json_params["alarm"]["password"]
      		params = {"app_id" => ENV["ONESIGNAL_APP_ID"], 
                    "headings" => {"en" => json_params["alarm"]["headings"]},
                    "contents" => {"en" => json_params["alarm"]["contents"]},
                    "included_segments" => ["All"]}
          
    	    uri = URI.parse('https://onesignal.com/api/v1/notifications')
    	    http = Net::HTTP.new(uri.host, uri.port)
    	    http.use_ssl = true
    	    
    	    request = Net::HTTP::Post.new(uri.path,
    	                                  'Content-Type'  => 'application/json;charset=utf-8',
    	                                  'Authorization' => ENV["ONESIGNAL_API_KEY"])
    	    request.body = params.as_json.to_json
    	    response = http.request(request)
      		
      		render :json => { message: "모든 유저에게 푸쉬알람 전송 성공", :pushalarm => { :headings => json_params["alarm"]["headings"], :contents => json_params["alarm"]["contents"] } }
    	else
    		render json: { errors: ['유효하지 않는 password 혹은 body'] }, status: :unauthorized
    	end
    end
  
    def user_config
        begin
            json_params = JSON.parse(request.body.read)
            maxPushCount = json_params["userConfig"]["maxPushCount"].to_i
            
            if maxPushCount < 0
                render json: {errors: ['pushCount 수치가 음수입니다. (Reject request)']}, :status => :bad_request
            else
                current_user.update(alarm_status: json_params["userConfig"]["alarmStatus"], max_push_count: maxPushCount)
                render :json => { :user => { :userId => current_user.id, :alarmStatus=> current_user.alarm_status, :maxPushCount => current_user.max_push_count } }
            end
        rescue
            render json: {errors: ['Invalid Body']}, :status => :bad_request
        end
    end
  
    def status
        arr = Array.new
        
        KeywordAlarm.where(app_user_id: current_user.id).each do |keyword|
            arr << keyword.title
        end
        
        if arr.empty?
            arr = []
        end
        
        render :json => { :userId => current_user.id, :userInfo => { :alarmStatus=> current_user.alarm_status, :maxPushCount => current_user.max_push_count, :keywordList => arr } }
    end
  
    def combine
        begin
            json_params = JSON.parse(request.body.read)
            keyword = KeywordAlarm.find_by(app_user_id: current_user.id, title: json_params["alarm"]["keywordTitle"])
            
            if keyword.nil?
                @keywordResult = KeywordAlarm.create(app_user_id: current_user.id, title: json_params["alarm"]["keywordTitle"])
                @dataJson = { :message => "'#{@keywordResult.title}' 키워드가 생성되었습니다.",
                                :keyword => {
                                    		:userId => current_user.id,
                                    		:keywordTitle => @keywordResult.title
    	                    }
                }
                
                render :json => @dataJson, :except => [:id, :created_at, :updated_at]
            else
                keyword.destroy
                render :json => { :message => "키워드가 삭제되었습니다." }
            end
        rescue
            render json: {errors: ['Invalid Body']}, :status => :bad_request
        end
    end
    
    def index
      	sql = "
      		SELECT DISTINCT *, CASE WHEN book_marks IS NULL THEN 'false' ELSE 'true' END AS is_bookmark FROM hit_products
      			LEFT JOIN book_marks ON book_marks.hit_product_id = hit_products.id
      			LEFT JOIN keyword_pushalarm_lists ON keyword_pushalarm_lists.hit_product_id = hit_products.id
      		WHERE keyword_pushalarm_lists.app_user_id = #{current_user.id}
      		ORDER BY date DESC;
      	"
      	@productData = ActiveRecord::Base.connection.execute(sql)
      	
      	arr = Array.new
      	
      	orderStack = 1
      	@productData.each do |data|
      		if data["is_bookmark"] == "true"
      			data["is_bookmark"] = true
    			else
    				data["is_bookmark"] = false
    			end
    			
      		arr.push([orderStack, data["keyword_title"], data["product_id"], data["title"], data["view"], data["comment"], data["like"], data["score"], "#{time_ago_in_words(data["date"])} 전", data["image_url"], data["is_sold_out"], data["dead_check"], data["is_title_changed"], data["url"], data["redirect_url"], data["is_bookmark"]])
      		orderStack += 1
      	end
      	
      	@result = keyword_pushalarm_list_data_push(arr, current_user.id)
      	render :json => { :userId => current_user.id, :pushList => @result }
    end
  
    def create
      	begin
    	  	json_params = JSON.parse(request.body.read)
    			keyword = KeywordAlarm.find_by(app_user_id: current_user.id, title: json_params["alarm"]["keywordTitle"])
    		  
    	    if keyword.nil?
    			@keywordResult = KeywordAlarm.create(app_user_id: current_user.id, title: json_params["alarm"]["keywordTitle"])
    			@dataJson = { :message => "'#{@keywordResult.title}' 키워드가 생성되었습니다.",
    										:keyword => {
    																	:userId => current_user.id,
    																	:keywordTitle => @keywordResult.title
    																}
    									}
    
    			render :json => @dataJson, :except => [:id, :created_at, :updated_at]
    		
    		else
    			render json: { errors: ['이미 키워드가 존재합니다.'] }, status: :forbidden
    		end
    	rescue
    		render json: {errors: ['Invalid Body']}, :status => :bad_request
    	end
    end
  
    def destroy
      	begin
    	  	json_params = JSON.parse(request.body.read)
    			keyword = KeywordAlarm.find_by(app_user_id: current_user.id, title: json_params["alarm"]["keywordTitle"])
    		  
    	    if keyword.nil?
    				render json: { errors: ['북마크가 존재하지 않습니다.'] }, status: :forbidden
    			
    		elsif keyword != nil
    			keyword.destroy
    			render :json => { :message => "북마크가 삭제되었습니다." }
    		end
    	rescue
    		render json: {errors: ['Invalid Body']}, :status => :bad_request
    	end
    end
end