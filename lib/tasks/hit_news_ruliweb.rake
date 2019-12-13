## rake hit_news_ruliweb:auto_collect
## 루리웹

namespace :hit_news_ruliweb do
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
    
    ### 루리웹 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    2.step(1, -1) do |index|
      begin
        puts "[루리웹 #{index}] 크롤링 시작!"
        @dataArray = Array.new
        
        # @current_page = @page.page_stack
        @browser.navigate().to "https://bbs.ruliweb.com/market/board/1020?page=#{index}"
        
        ## find_element랑 find_elements의 차이
        @content = @browser.find_elements(css: '#board_list > div > div.board_main.theme_default.theme_white > table > tbody > tr')
        
        @content.each_with_index do |t, j|
          @timeCheck = t.find_element(css: 'td.time').text
          @noticeCheck = t.find_element(css: 'td.divsn').text rescue @noticeCheck = ""
          if (not @noticeCheck.include?("전체공지") || @noticeCheck.include?("공지"))
            @webCreatedTime = @timeCheck
            
            @title = t.find_element(css: "a.deco").text
            @view = t.find_element(css: 'td.hit').text.to_i
            @comment = t.find_element(css: "td.subject > div.relative > span.num_reply > span.num").text.to_i rescue @comment = 0
            @like = t.find_element(css: 'td.recomd > span').text.to_i rescue @like = 0
            @score = @view/2 + @like*150 + @comment*30
            @url = t.find_element(tag_name: "a.deco").attribute("href")
            @url = @url.gsub("https://bbs.ruliweb.com", "https://m.ruliweb.com").gsub("?page=#{index}", "")
    
            @sailStatus = false rescue @sailStatus = false
            if not (@sailStatus == false)
              @sailStatus = true
            end
            
            begin
              docs = Nokogiri::HTML(open(@url))
              @time = docs.css("span.regdate").text.gsub(/\(|\)/, "").to_time - 9.hours
              @imageUrlCollect = docs.at("div.view_content").at("img").attr('src')
              
              if @imageUrlCollect.include?("ruliweb.com/img/") == false
                @imageUrl = "#{@imageUrlCollect.gsub("http", "https")}"
              elsif @imageUrlCollect.include?("ruliweb.com/img/") == true
                @imageUrl = "https:" + "#{@imageUrlCollect}"
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
            # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
            # puts "@imageUrl : #{@imageUrl}"
            # puts "==============================================="
           
            # puts "Process : Pushing..."
            @dataArray.push(["ruliweb_#{SecureRandom.hex(6)}", @time, @title, "루리웹", @sailStatus, @view, @comment, @like, @score, @url, @imageUrl])
            # HitProduct.create(product_id: "ruliweb_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "루리웹", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
          else
            next
          end
        end
      rescue
        next
      end
      
      @dataArray.each do |currentData|
        puts "[루리웹] Process : Data Writing..."
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
          if (currentData[8] > @previousData.score)
            @previousData.update(score: currentData[8])
          end
          
        end
        
        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10])
      end
      
    end
    
    @browser.quit
    
  end

end
