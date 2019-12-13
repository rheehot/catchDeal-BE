## rake alive_check:check
## 페이지가 살아있는지 체크

namespace :alive_check do
  task check: :environment do
    
    def articleCheck(id, url)
      begin
        timeout(5) do
          doc = Nokogiri::HTML(open(url)).text
        
        
          if doc.include? "존재하지 않습니다" || (not doc.include? "레벨9는 코멘트를 작성한 후 1분이 경과해야 새 코멘트를 작성할 수 있습니다.")
            puts "글 없음"
            HitProduct.find(id).update(dead_check: true)
          end
        end
        
        return 1
        
      rescue OpenURI::HTTPError => e
        puts "글 없음(404 에러)"
        HitProduct.find(id).update(dead_check: true)
        return 1
      rescue Timeout::Error
        puts "타임아웃"
        return 0
      end
      
    end
    
    HitProduct.all.each do |pageCheck|
      # puts "**[Job count : 1]  페이지 체크 시작"
      @result = articleCheck(pageCheck.id, pageCheck.url)
    end
	
	  sleep(120)
	
	  HitProduct.all.each do |pageCheck|
      # puts "** [Job count : 2] 페이지 체크 시작"
      @result = articleCheck(pageCheck.id, pageCheck.url)
    end
    
  end
end
