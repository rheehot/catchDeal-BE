## rake hit_news_ppom:auto_collect
## 뽐뿌

namespace :hit_news_ppom do
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
    
    def data_write(dataArray)
      dataArray.each do |currentData|
        puts "[뽐뿌] Process : Data Writing..."
        @previousData = HitProduct.find_by(url: currentData[9])
        
        if @previousData != nil
        
          ## 제목 변경 체크
          if (currentData[2] != @previousData.title)
            @previousData.update(title: currentData[2], is_title_changed: true)
          end
  		
          
          ## 이미지 변경 체크
          if (currentData[10] != @previousData.image_url)
            @previousData.update(image_url: currentData[10])
          end
  		
          
          ## score 변경 체크
          if (currentData[8] > @previousData.score)
            @previousData.update(view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8])
          end
  		
          
          ## 판매상태 체크
          if (@previousData.is_sold_out == false && currentData[4] == true)
            @previousData.update(is_sold_out: true)
          end
          
        end
        
        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10])
      end
    end
    
    def crawl_ppom(index, url, failStack)
      
      begin
        puts "[뽐뿌 #{index}] 크롤링 시작!"
        @dataArray = Array.new
        
        @browser.navigate().to "#{url}"
        
        ## find_element랑 find_elements의 차이
        @content = @browser.find_elements(css: 'li.none-border')
        
        @content.each_with_index do |t, w|
          if (index == 1 && w >= 15)
            next
          end
          @title = t.find_element(css: 'span.cont').text
          
          # @brand = @title[/\[(.*?)\]/, 1]
          @info = t.find_element(css: "li.exp > span:nth-child(4)").text.gsub("[", "").gsub("]", "").split("/")
          @view = @info[0].gsub(" ", "").to_i
          
          @time = t.find_element(css: "li.exp > time").text
          if @time.include?(":")
            @time = Time.zone.now.strftime('%Y-%m-%d') + " #{@time}"
          elsif @time.include?("-")
            @time = "20" + @time
          elsif @time.nil?
            @time = Time.zone.now.strftime('%Y-%m-%d %H:%M')
          end
          @time = @time.to_time - 9.hours
          
          @comment = t.find_element(css: 'span.rp').text.to_i rescue @comment = 0
          @like = @info[1].gsub(" ", "").to_i
          @score = @view/1.5 + @like*300 + @comment*30
          
          @sailStatus = t.find_element(tag_name: "span.cont > span").attribute("style") rescue @sailStatus = false
          
          if @sailStatus != false
            @sailStatus = true
          end
          
          @urlMobile = t.find_element(tag_name: "a").attribute("href")
          @urlExtract = CGI::parse(@urlMobile)
          @urlPostNo = @urlExtract['no'].to_a[0]
          @url = "http://www.ppomppu.co.kr/zboard/view.php?id=ppomppu&no=" + @urlPostNo
          
          
          @imageUrlCollect = t.find_element(css: 'img').attribute("src")
          @imageUrl = "#{@imageUrlCollect.gsub("http", "https")}"
          
          if @imageUrl.include?("noimage") || @imageUrl.include?("no_img")
            @imageUrl = nil
          end
          
          if @imageUrl != nil && @imageUrl.include?("https://cfile")
            @imageUrl = @imageUrl.gsub("https:", "http:")
          end
          
          
          ## Console 확인용
          # puts "index : #{index}"
          # puts "title : #{@title} / time : #{@time} / view : #{@view}"
          # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
          # puts "==============================================="
          
          @dataArray.push(["ppom_#{SecureRandom.hex(6)}", @time, @title, "뽐뿌", @sailStatus, @view, @comment, @like, @score, @url, @imageUrl])
          # @newHotDeal = HitProduct.create(product_id: "ppom_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "뿜뿌", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
        end
        
        data_write(@dataArray)
        return 1
        
      rescue Timeout::Error
        # puts "crawl_ppom failStack : #{failStack}"
        # puts "타임아웃 에러 발생, 크롤링 재시작"
        
        if failStack == 1
          return 0
        else
          return crawl_ppom(index, url, failStack+1)
        end
      end
    end
    
    ### 뿜뿌 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    for index in 1..2
      @result = crawl_ppom(index, "http://m.ppomppu.co.kr/new/bbs_list.php?id=ppomppu&page=#{index}", 0)
      # puts "@result : #{@result}"
    end
    
    @browser.quit
    
  end
end