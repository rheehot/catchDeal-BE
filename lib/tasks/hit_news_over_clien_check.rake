## rake hit_news_over_clien_check:auto_collect
## 클리앙

namespace :hit_news_over_clien_check do
  desc "TODO"
  task auto_collect: :environment do

    require 'selenium-webdriver'
    Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp

    ## 헤드리스 개념 : https://beomi.github.io/2017/09/28/HowToMakeWebCrawler-Headless-Chrome/
    options = Selenium::WebDriver::Chrome::Options.new # 크롬 헤드리스 모드 위해 옵션 설정
    options.add_argument('--disable-extensions')
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--no-sandbox')
    @browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
    @browser2 = Selenium::WebDriver.for :chrome, options: options
    
    def collect_last_data(urlId, failStack)
      @browser2.navigate().to "https://www.clien.net/service/board/jirum/#{urlId}"
      begin
        time = @browser2.find_element(css: "#div_content > div.post_view > div.post_author > span:nth-child(1)").text
        # puts "time : #{time}"
      rescue
        if failStack == 4
          # puts "실패"
          return 0
        else
          # puts "재시도..."
          return collect_last_data(urlId, failStack+1)
        end
      end
      
      return @browser2
    end
    
    def data_modify(data)
      data.each do |currentData|
        @previousData = HitProduct.find_by(url: currentData[9])
        puts "[딜바다 Over Check] Process : Data Modify..."
        
        if @previousData != nil
        
          ## 제목 변경 체크
          if (currentData[2].to_s != @previousData.title.to_s)
            @previousData.update(title: currentData[2].to_s, is_title_changed: true)
          end
  		
          
          ## 이미지 변경 체크
          if (currentData[10].to_s != @previousData.image_url.to_s)
            @previousData.update(image_url: currentData[10].to_s)
          end
  		
          
          ## score 변경 체크
          if (currentData[8].to_i > @previousData.score.to_i)
            @previousData.update(view: currentData[5].to_i, comment: currentData[6].to_i, like: currentData[7].to_i, score: currentData[8].to_i)
          end
  		
          
          ## 판매상태 체크
          if (@previousData.is_sold_out == false && currentData[4] == true)
            @previousData.update(is_sold_out: true)
          end
          
          
          ## RedirectUrl 변경 체크
          if (currentData[11].to_s != @previousData.redirect_url.to_s)
            @previousData.update(redirect_url: currentData[11].to_s)
          end
          
        end

      end
    end
    
    ### 클리앙 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    def crawl_clien(index, url, failStack)
      begin
        puts "[클리앙(목록 초과) #{index}] 검사 시작!"
        @dataArray = Array.new
        
        # @current_page = @page.page_stack
        @browser.navigate().to "#{url}"
        
        ## find_element랑 find_elements의 차이
        @content = @browser.find_elements(css: 'div.list_item.symph_row')
        
        @content.each do |t|
          @title = t.find_element(css: 'span.list_subject').text
          @view = t.find_element(css: 'span.hit').text.to_i
          @comment = t.find_element(css: "div.list_title > a > span").text.to_i rescue @comment = 0
          @like = t.find_element(css: 'span.list_votes').text.to_i
          @score = @view/1.5 + @like*400 + @comment*30
          @urlId = t.find_element(tag_name: "a").attribute("href").split("/").last.split("?").first
          @url = "https://www.clien.net/service/board/jirum/#{@urlId}"
  
          @sailStatus = t.find_element(css: "span.icon_info") rescue @sailStatus = false
          if @sailStatus != false
            @sailStatus = true
          end
          
          @browser2 = collect_last_data(@urlId, 0)
          
          begin
            redirectUrl = @browser2.find_element(css: "a.url").attribute("href")
          rescue
            redirectUrl = ""
          end
          
          if redirectUrl.nil? || redirectUrl.empty?
            begin
              redirectUrl = @browser2.find_element(css: "div.attached_link").text.split(" ")[1]
            rescue
              redirectUrl = nil
            end
            if redirectUrl.nil? || redirectUrl.empty?
              redirectUrl = nil
            end
          end
          
          time = @browser2.find_element(css: "#div_content > div.post_view > div.post_author > span:nth-child(1)").text.to_time - 9.hours
          begin
            imageUrlCollect = @browser2.find_element(css: "img.fr-dib").attribute('src')
          rescue
            imageUrlCollect = nil
          end
          
          if imageUrlCollect != nil && imageUrlCollect.include?("cdn.clien.net") == false
            imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
          elsif imageUrlCollect != nil && imageUrlCollect.include?("cdn.clien.net") == true
            imageUrl = imageUrlCollect
          end
          
          if imageUrl != nil && imageUrl.include?("https://cfile")
            imageUrl = imageUrl.gsub("https:", "http:")
          end
          
          if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
            redirectUrl = ""
          end
          
          ## Console 확인용
          # puts "i : #{index}"
          # puts "title : #{@title}"
          # puts "title : #{@title} / time : #{time} / view : #{@view}"
          # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
          # puts "==============================================="
          
          @dataArray.push(["clien_#{SecureRandom.hex(6)}", time, @title, "클리앙", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
          # @newHotDeal = HitProduct.create(product_id: "clien_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "클리앙", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
        end
        
        data_modify(@dataArray)
        
        return 1
      rescue Timeout::Error
        # puts "crawl_ppom failStack : #{failStack}"
        # puts "타임아웃 에러 발생, 크롤링 재시작"
        
        if failStack == 1
          return 0
        else
          return crawl_clien(index, url, failStack+1)
        end
      end
    end
    
    ### 뿜뿌 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    2.step(0, -1) do |index|
      @result = crawl_clien(index, "https://www.clien.net/service/board/jirum?po=#{index}", 0)
      # puts "@result : #{@result}"
    end
    
    @browser.quit
    @browser2.quit
    
  end

end