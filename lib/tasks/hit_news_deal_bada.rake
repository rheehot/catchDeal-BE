## rake hit_news_deal_bada:auto_collect
## 딜바다

namespace :hit_news_deal_bada do
  desc "TODO"
  task auto_collect: :environment do
    
    require 'selenium-webdriver'
    if Rails.env.development?
      # Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
    else
      Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
    end
    
    ## 헤드리스 개념 : https://beomi.github.io/2017/09/28/HowToMakeWebCrawler-Headless-Chrome/
    options = Selenium::WebDriver::Chrome::Options.new # 크롬 헤드리스 모드 위해 옵션 설정
    options.add_argument('--disable-gpu') # 크롬 헤드리스 모드 사용 위해 disable-gpu setting
    options.add_argument('--headless') # 크롬 헤드리스 모드 사용 위해 headless setting
    @browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
    
    ### 딜바다 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    3.step(1, -1) do |index|
      begin
        puts "[딜바다 #{index}] 크롤링 시작!"
        @dataArray = Array.new
        
        @browser.navigate().to "http://www.dealbada.com/bbs/board.php?bo_table=deal_domestic&page=#{index}"
        
        ## find_element랑 find_elements의 차이
        @content = @browser.find_elements(css: 'table.hoverTable > tbody > tr')
        
        @content.each do |t|
          @titleContent = t.find_element(css: "td.td_subject > a").text.strip
          @noticeCheck = t.find_element(css: "a.bo_cate_link").text.strip
          
          @previousData = HitProduct.find_by(title: @title, website: "딜바다")
          if (@previousData != nil && @titleContent.split("\n")[0].include?("블라인드 처리된 게시물입니다."))
            @previousData.destroy
          end
          
          if (not @titleContent.split("\n")[0].include?("블라인드 처리") || @noticeCheck == "공지" || @titleContent.split("\n")[0].include?("확인 가능합니다."))
            @webCreatedTime = t.find_element(css: 'td.td_date').text
            
            @title = @titleContent.split("\n")[0]
            
            @view = t.find_element(css: 'td:nth-child(7)').text.to_i
            @comment = @titleContent.split("\n")[1].to_i rescue @comment = 0
            @like = t.find_element(css: 'td.td_num_g > span:nth-child(1)').text.to_i
            @score = @view/2 + @like*30 + @comment*10
            @url = t.find_element(tag_name: "td.td_subject > a").attribute("href").gsub("&page=#{index}", "")
    
            @sailStatus = t.find_element(css: "td.td_subject > a > img") rescue @sailStatus = false
            
            if @sailStatus != false
              @sailStatus = true
            end
            
            begin
              docs = Nokogiri::HTML(open(@url))
              @time = docs.at("#bo_v_info > div:nth-child(2) > span:nth-child(8)").text.to_time - 9.hours
              
              @imageUrlCollect = docs.at("div#bo_v_con").at("img").attr('src')
              
              if @imageUrlCollect.include?("cdn.dealbada.com") == false
                @imageUrl = "#{@imageUrlCollect.gsub("http", "https")}"
              elsif @imageUrlCollect.include?("cdn.dealbada.com") == true
                @imageUrl = @imageUrlCollect.gsub("http", "https")
              end
              
              if @imageUrl != nil && @imageUrl.include?("https://cfile")
                @imageUrl = @imageUrl.gsub("https:", "http:")
              end
            rescue
              @imageUrl = nil
            end
            
            ## Console 확인용
            # puts "i : #{index}"
            # puts "title : #{@title} / time : #{@time} / view : #{@view}"
            # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / sailStatus : #{@sailStatus} / url : #{@url}"
            # puts "==============================================="
            
            @dataArray.push(["dealBaDa_#{SecureRandom.hex(6)}", @time, @title, "딜바다", @sailStatus, @view, @comment, @like, @score, @url, @imageUrl])
            # @newHotDeal = HitProduct.create(product_id: "dealBaDa_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "딜바다", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
          else
            next
          end
        end
      rescue
        next
      end
      
      @dataArray.each do |currentData|
        puts "[딜바다] Process : Data Writing..."
        @previousData = HitProduct.find_by(url: currentData[9])
        
        if @previousData != nil
          
          ## 제목 변경 체크
          if (currentData[2] != @previousData.title)
            @previousData.update(title: currentData[2])
          end
  		
          
          ## 이미지 변경 체크
          if (currentData[10] != @previousData.image_url)
            @previousData.update(image_url: currentData[10])
          end
          
  		
          ## score 변경 체크
          if (currentData[8].to_s > @previousData.score.to_s)
            @previousData.update(score: currentData[8])
          end
  		
          
          ## 판매상태 체크
          if (@previousData.is_sold_out == false && currentData[4] == true)
            @previousData.update(is_sold_out: true)
          end
          
        end
        
        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10])
      end
      
    end
    
    @browser.quit
    
  end

end