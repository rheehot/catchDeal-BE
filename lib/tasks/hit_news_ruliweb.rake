<<<<<<< HEAD
## rake hit_news_ruliweb:auto_collect
## 루리웹

namespace :hit_news_ruliweb do
  desc "TODO"
  task auto_collect: :environment do

    def data_write(dataArray)
      dataArray.each do |currentData|
        puts "[루리웹] Process : Data Writing..."
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


          ## RedirectUrl 변경 체크
          if (currentData[11].to_s != @previousData.redirect_url.to_s)
            @previousData.update(redirect_url: currentData[11].to_s)
          end

        end

        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10], redirect_url: currentData[11])
      end
    end

    def crawl_ruliweb(index, url, failStack)

      begin
        puts "[루리웹 #{index}] 크롤링 시작!"
        @dataArray = Array.new

        # @current_page = @page.page_stack
        @browser.navigate().to "#{url}"

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
            @score = @view/1.5 + @like*400 + @comment*30
            @url = t.find_element(css: "a.deco").attribute("href")
            @url = @url.gsub("https://bbs.ruliweb.com", "https://m.ruliweb.com").gsub("?page=#{index}", "")

            @sailStatus = false rescue @sailStatus = false
            if not (@sailStatus == false)
              @sailStatus = true
            end

            begin
              docs = Nokogiri::HTML(open(@url))
              redirectUrl = docs.css("div.source_url").text.split("|")[1].gsub(" ", "")
              if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
                redirectUrl = ""
              end

              time = docs.css("span.regdate").text.gsub(/\(|\)/, "").to_time - 9.hours
              imageUrlCollect = docs.at("div.view_content").at("img").attr('src')

              if imageUrlCollect.include?("ruliweb.com/img/") == false
                imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
              elsif imageUrlCollect.include?("ruliweb.com/img/") == true
                imageUrl = "https:" + "#{imageUrlCollect}"
              end

              if imageUrl != nil && imageUrl.include?("https://cfile")
                imageUrl = imageUrl.gsub("https:", "http:")
              end
            rescue
              imageUrl = nil
            end

            ## Console 확인용
            # puts "i : #{index}"
            # puts "title : #{@title} / time : #{time} / view : #{@view}"
            # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
            # puts "@imageUrl : #{imageUrl}"
            # puts "==============================================="

            # puts "Process : Pushing..."
            @dataArray.push(["ruliweb_#{SecureRandom.hex(6)}", time, @title, "루리웹", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
            # HitProduct.create(product_id: "ruliweb_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "루리웹", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
          else
            next
          end
        end
        data_write(@dataArray)
        return 1

      rescue Timeout::Error
        # puts "crawl_ppom failStack : #{failStack}"
        # puts "타임아웃 에러 발생, 크롤링 재시작"

        if failStack == 1
          return 0
        else
          return main_ruliweb_chrome(index, url, failStack+1)
        end
      end
    end

    def main_ruliweb_chrome
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

      ### 루리웹 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 3)
      for index in 1..3
        @result = crawl_ruliweb(index, "https://bbs.ruliweb.com/market/board/1020?page=#{index}", 0)
        # puts "@result : #{@result}"
      end

      @browser.quit
    end

    main_ruliweb_chrome

  end
=======
## rake hit_news_ruliweb:auto_collect
## 루리웹

namespace :hit_news_ruliweb do
  desc "TODO"
  task auto_collect: :environment do

    def data_write(dataArray)
      dataArray.each do |currentData|
        puts "[루리웹] Process : Data Writing..."
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


          ## RedirectUrl 변경 체크
          if (currentData[11].to_s != @previousData.redirect_url.to_s)
            @previousData.update(redirect_url: currentData[11].to_s)
          end

        end

        HitProduct.create(product_id: currentData[0], date: currentData[1], title: currentData[2], website: currentData[3], is_sold_out: currentData[4], view: currentData[5], comment: currentData[6], like: currentData[7], score: currentData[8], url: currentData[9], image_url: currentData[10], redirect_url: currentData[11])
      end
    end

    def crawl_ruliweb(index, url, failStack)

      begin
        puts "[루리웹 #{index}] 크롤링 시작!"
        @dataArray = Array.new

        # @current_page = @page.page_stack
        @browser.navigate().to "#{url}"

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
            @score = @view/1.5 + @like*400 + @comment*30
            @url = t.find_element(css: "a.deco").attribute("href")
            @url = @url.gsub("https://bbs.ruliweb.com", "https://m.ruliweb.com").gsub("?page=#{index}", "")

            @sailStatus = false rescue @sailStatus = false
            if not (@sailStatus == false)
              @sailStatus = true
            end

            begin
              docs = Nokogiri::HTML(open(@url))
              redirectUrl = docs.css("div.source_url").text.split("|")[1].gsub(" ", "")
              if redirectUrl.nil? || redirectUrl.empty? || (not redirectUrl.include? "http") || (not redirectUrl.include? "https")
                redirectUrl = ""
              end

              time = docs.css("span.regdate").text.gsub(/\(|\)/, "").to_time - 9.hours
              imageUrlCollect = docs.at("div.view_content").at("img").attr('src')

              if imageUrlCollect.include?("ruliweb.com/img/") == false
                imageUrl = "#{imageUrlCollect.gsub("http", "https")}"
              elsif imageUrlCollect.include?("ruliweb.com/img/") == true
                imageUrl = "https:" + "#{imageUrlCollect}"
              end

              if imageUrl != nil && imageUrl.include?("https://cfile")
                imageUrl = imageUrl.gsub("https:", "http:")
              end
            rescue
              imageUrl = nil
            end

            ## Console 확인용
            # puts "i : #{index}"
            # puts "title : #{@title} / time : #{time} / view : #{@view}"
            # puts "comment : #{@comment} / like : #{@like} / score : #{@score} / url : #{@url}"
            # puts "@imageUrl : #{imageUrl}"
            # puts "==============================================="

            # puts "Process : Pushing..."
            @dataArray.push(["ruliweb_#{SecureRandom.hex(6)}", time, @title, "루리웹", @sailStatus, @view, @comment, @like, @score, @url, imageUrl, redirectUrl])
            # HitProduct.create(product_id: "ruliweb_#{SecureRandom.hex(6)}", date: @time, title: @title, website: "루리웹", is_sold_out: @sailStatus, view: @view, comment: @comment, like: @like, score: @score, url: @url, image_url: @imageUrl)
          else
            next
          end
        end
        data_write(@dataArray)
        return 1

      rescue Timeout::Error
        # puts "crawl_ppom failStack : #{failStack}"
        # puts "타임아웃 에러 발생, 크롤링 재시작"

        if failStack == 1
          return 0
        else
          return main_ruliweb_chrome(index, url, failStack+1)
        end
      end
    end

    def main_ruliweb_chrome
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

      ### 루리웹 핫딜 게시글 크롤링 (목차탐색 : 1 ~ 3)
      for index in 1..3
        @result = crawl_ruliweb(index, "https://bbs.ruliweb.com/market/board/1020?page=#{index}", 0)
        # puts "@result : #{@result}"
      end

      @browser.quit
    end

    main_ruliweb_chrome

  end
>>>>>>> a996e89d14d635c35879401b787d17c820f64ca0
end