## rake chrome_check:auto_job

namespace :chrome_check do
  desc "TODO"
  task auto_job: :environment do

		def main_chromium_check_chrome
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

			begin
				@browser = Selenium::WebDriver.for :chrome, options: options # 실레니움 + 크롬 + 헤드리스 옵션으로 브라우저 실행
					#@errorMessage = $!
					#SendmailMailer.email_notification(@errorMessage).deliver_now
			rescue
				puts "에러 발생! 관리자에게 메일이 발송됩니다.."
				@errorMessage = $!
				AdminMailer.alert(@errorMessage).deliver_now
			end

			@browser.quit
		end

		main_chromium_check_chrome
    
  end

end
