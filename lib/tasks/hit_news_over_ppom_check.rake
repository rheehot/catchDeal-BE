## rake hit_news_over_ppom_check:auto_collect
## 뽐뿌

namespace :hit_news_over_ppom_check do
  desc "TODO"
  task auto_collect: :environment do

    def data_write(dataArray)
      dataArray.each do |currentData|
        puts "[뽐뿌 Over Check] Process : Data Modify..."
        @previousData = HitProduct.find_by(url: currentData[9])

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

        else
          next
        end
      end
    end

    def crawl_ppom(index, url, failStack)

      begin
        puts "[뿜뿌(목록 초과) #{index}] 검사 시작!"
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
            @time = Time.now.in_time_zone("Asia/Seoul").strftime('%Y-%m-%d') + " #{@time}"
          elsif @time.include?("-")
            @time = "20" + @time
          elsif @time.nil?
            @time = Time.now.in_time_zone("Asia/Seoul").strftime('%Y-%m-%d %H:%M')
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

    def main_ppom_check_data_chrome
      Selenium::WebDriver::Chrome.driver_path = `which chromedriver-helper`.chomp
      options = Selenium::WebDriver::Chrome::Options.new

      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
      options.add_argument("--window-size=1280x1696")
      options.add_argument("--disable-application-cache")
      options.add_argument("--disable-infobars")
      options.add_argument("--no-sandbox")
      options.add_argument('--disable-dev-shm-usage')
      options.add_argument("--hide-scrollbars")
      options.add_argument("--enable-logging")
      options.add_argument("--log-level=0")
      options.add_argument("--single-process")
      options.add_argument("--ignore-certificate-errors")
      options.add_argument("--homedir=/tmp")
      @browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행

      ### 뿜뿌 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 2)
      for index in 3..7
        @result = crawl_ppom(index, "http://m.ppomppu.co.kr/new/bbs_list.php?id=ppomppu&page=#{index}", 0)
        # puts "@result : #{@result}"
      end

      @browser.quit
    end

    main_ppom_check_data_chrome
    
  end
end