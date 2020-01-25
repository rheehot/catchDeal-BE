## rake keyword:alarm
## API 문서 : https://documentation.onesignal.com/reference#create-notification

namespace :keyword do
  desc "TODO"
  task alarm: :environment do
    
    def push_alarm_main
      userTotalPushCount = Hash.new(0)
      
      KeywordAlarm.all.eager_load(:app_user).group_by(&:title).each do |keywordList|
        # puts "keywordList : #{keywordList[0]}"
        alarmUserList = Array.new
        
        keywordList[1].each do |user|
          alarmUserList << user.app_user.app_player
        end
        # puts "[#{keywordList[0]}] #{alarmUserList}"
        
        ## 물건 탐색 및 알람 전송
        HitProduct.where(:created_at => Time.now.in_time_zone("Asia/Seoul")-1.hour...Time.now.in_time_zone("Asia/Seoul")).where("title LIKE ?", "%#{keywordList[0]}%").each do |product|
          alarmUserList.each do |alarmUser|
            # puts "유저 번호 : #{AppUser.find_by(app_player: alarmUser).app_player}"
            # puts "유저 최대 push허용설정 : #{AppUser.find_by(app_player: alarmUser).max_push_count}"
            
            if (AppUser.find_by(app_player: alarmUser).alarm_status == true && AppUser.find_by(app_player: alarmUser).max_push_count.to_i > userTotalPushCount["#{alarmUser}"].to_i)
              userTotalPushCount[alarmUser] += 1
              # puts "키워드 : #{keywordList[0]} / alarmUser : #{alarmUser}(#{userTotalPushCount["#{alarmUser}"]}) / title : #{product.title}"
              # puts "hashCounts : #{userTotalPushCount}"
              
              ## 특정 대상에게 푸쉬
              params = {"app_id" => ENV["ONESIGNAL_APP_ID"], 
                      "headings" => {"en" => "캐치가 [#{keywordList[0]}] 키워드 상품을 물어왔어요!"},
                      "contents" => {"en" => product.title},
                      "url" => product.url,
                      "include_player_ids" => [alarmUser]}
            
              uri = URI.parse('https://onesignal.com/api/v1/notifications')
              http = Net::HTTP.new(uri.host, uri.port)
              http.use_ssl = true
              
              request = Net::HTTP::Post.new(uri.path,
                                            'Content-Type'  => 'application/json;charset=utf-8',
                                            'Authorization' => ENV["ONESIGNAL_API_KEY"])
              request.body = params.as_json.to_json
              response = http.request(request)
              # puts "Debugging Response : #{response.body}"
            
            else
              next
            end
            
          end
        end
      end
    end
    
    push_alarm_main
    
  end
end