## rake hit_news_clien:auto_collect
## 클리앙

namespace :hit_news_clien do
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
    
    ### 클리앙 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
    1.step(0, -1) do |i|
      begin
        puts "[클리앙 #{i}] 크롤링 시작!"
        @dataArray = Array.new
        
        # @current_page = @page.page_stack
        @browser.navigate().to "https://www.clien.net/service/board/jirum?po=#{i}"
        
        ## find_element랑 find_elements의 차이
        @content = @browser.find_elements(css: 'div.list_item.symph_row')
        
        @content.each do |t|
          @title = t.find_element(css: 'span.list_subject').text
          @view = t.find_element(css: 'span.hit').text.to_i
          @comment = t.find_element(css: "div.list_title > a > span").text.to_i rescue @comment = 0
          @like = t.find_element(css: 'span.list_votes').text.to_i
          @score = @view/1.5 + @like*250 + @comment*70
          @url = t.find_element(tag_name: "a").attribute("href")
  
          @sailStatus = t.find_element(css: "span.icon_info") rescue @sailStatus = false
          if @sailStatus != false
            @sailStatus = true
          end
          
          # ## 클리앙 같은 경우, 외부 이미지 URL은 수집 못합니다.
          begin
            docs = Nokogiri::HTML(open(@url))
            @time = docs.at("#div_content > div.post_view > div.post_author > span:nth-child(1)").text.to_time - 9.hours
            @imageUrlCollect = docs.at("img.fr-dib").attr('src')
            
            if @imageUrlCollect.include?("cdn.clien.net") == false
              @imageUrl = "#{@imageUrlCollect.gsub("http", "https")}"
            elsif @imageUrlCollect.include?("cdn.clien.net") == true
              @imageUrl = @imageUrlCollect
            end
            
            if @imageUrl != nil && @imageUrl.include?("https://cfile")
              @imageUrl = @imageUrl.gsub("https:", "http:")
            end
          rescue
            @imageUrl = nil
          end
          
          ## Console 확인용
          # puts "i : #{i}"
          # puts "title : #{@title}"
          # puts "title : #{@title} / time : #{@time} / view : #{@view}"
          # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
          # puts "==============================================="
          
          @dataArray.push(["clien_#{SecureRandom.hex(6)}", @time, @title, "클리앙", @sailStatus, @view, @comment, @like, @score, @url, @imageUrl])
          # @newHotDeal = HitProduct.create(product_id: "clien_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "클리앙", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
        end
      rescue
        next
      end
      
      @dataArray.each do |currentData|
        puts "[클리앙] Process : Data Writing..."
        
        ## 제목 변경 체크
        @previousUrl = HitProduct.find_by(url: currentData[9], website: currentData[3])
        if (@previousUrl != nil && currentData[2] != @previousUrl.title)
          @previousUrl.update(title: currentData[2])
        end
		
        
        ## 이미지 변경 체크
        if (@previousUrl != nil && currentData[10] != @previousUrl.image_url)
          @previousUrl.update(image_url: currentData[10])
        end
		
        
        ## score 변경 체크
        @previousProduct = HitProduct.find_by(title: currentData[2], website: currentData[3])
        if (@previousProduct != nil && currentData[8] > @previousProduct.score)
          @previousProduct.update(score: currentData[8])
        end
		
        
        ## 판매상태 체크
        @previousProduct = HitProduct.find_by(title: currentData[2], website: currentData[3], is_sold_out: false)
        if (@previousProduct != nil && currentData[4] == true)
          @previousProduct.update(is_sold_out: true)
        end
        
        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10])
      end
        
    end
    
    @browser.quit
    
  end

end
